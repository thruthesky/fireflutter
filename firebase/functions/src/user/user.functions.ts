import { onValueWritten } from "firebase-functions/v2/database";
import { Config } from "../config";
import { ServerValue, getDatabase } from "firebase-admin/database";
import { getFirestore } from "firebase-admin/firestore";
import { MessagingService } from "../messaging/messaging.service";
import { isCreate } from "../library";


import { onRequest } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v1";
import { UserService } from "./user.service";


/**
 * 전화번호 가입을 한다.
 *
 * 로그인을 하지 않는다. 즉, 이미 전화번호가 가입되어져 있으면 에러를 낸다.
 *
 * @param request request
 * @param response response
 *
 * @returns response
 *
 * @see READMD.md
 */
export const phoneNumberRegister = onRequest(async (request, response) => {
    logger.info("phoneNumberRegister: request.body", request.body);
    const res = await UserService.createAccountWithPhoneNumber({ ...request.body, ...request.query });
    response.send(res);
});


/**
 * User likes
 */
export const userLike = onValueWritten(
    `${Config.whoILike}/{myUid}/{targetUid}`,
    async (event): Promise<void> => {
        const db = getDatabase();
        const myUid = event.params.myUid;
        const targetUid = event.params.targetUid;

        // created or updated
        if (event.data.after.exists()) {
            await db.ref(`${Config.whoLikeMe}/${targetUid}`).update({ [myUid]: true });
            await db.ref(`users/${targetUid}`).update({ noOfLikes: ServerValue.increment(1) });
        } else {
            // deleted
            await db.ref(`${Config.whoLikeMe}/${targetUid}/${myUid}`).remove();
            await db.ref(`users/${targetUid}`).update({ noOfLikes: ServerValue.increment(-1) });
        }

        // Send message to the target user
        if (isCreate(event)) {
            await MessagingService.sendMessageWhenUserLikeMe({
                uid: targetUid,
                otherUid: myUid,
            });
        }
    },
);

/**
 * User CRUD
 * 
 * Mirror the user data to Firestore
 */
export const userMirror = onValueWritten(
    `${Config.users}/{uid}`,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    async (event): Promise<any> => {
        const firestore = getFirestore();
        const userUid = event.params.uid;

        if (event.data.before.exists()) {
            // Updated
            const userData = event.data.after.val();
            // noOfLikes 는 자주 업데이트 되므로, firestore /users 를 목록 할 때, FirestoreListView 등에서 flickering 이 발생한다.
            // 그래서, noOfLikes 필드는 삭제한다.
            delete userData.noOfLikes;
            const searchDisplayName = userData.displayName.trim().toLowerCase().replace(/\s+/g, "");
            return await firestore.collection(Config.users).doc(userUid).set({ ...userData, searchDisplayName: searchDisplayName }, { merge: true });
        }
        if (!event.data.after.exists()) {
            // Deleted
            return await firestore.collection(Config.users).doc(userUid).delete();
        }
        // Created
        const data = event.data.after.val();
        const searchDisplayName = data.displayName.trim().toLowerCase().replace(/\s+/g, "");
        return await firestore.collection(Config.users).doc(userUid).set({ ...data, searchDisplayName: searchDisplayName });
    }
);





/**
 * User delete account
 *
 * This will delete user account from Firebase Auth, Realtime Database, Firestore.
 */
export const userDeleteAccount = onValueWritten(`${Config.commands}/{uid}/deleteAccount`, async (event) => {
    if (event.data.after.val() === true) {
        await UserService.deleteAccount(event.params.uid);
    }
});

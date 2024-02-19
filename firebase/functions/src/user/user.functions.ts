import { onValueWritten } from "firebase-functions/v2/database";
import { Config } from "../config";
import { ServerValue, getDatabase } from "firebase-admin/database";
import { getFirestore } from "firebase-admin/firestore";

/**
 * User likes
 */
export const userLike = onValueWritten(
    `${Config.userWhoILike}/{myUid}/{targetUid}`,
    async (event): Promise<void> => {
        const db = getDatabase();
        const myUid = event.params.myUid;
        const targetUid = event.params.targetUid;

        // created or updated
        if (event.data.after.exists()) {
            await db.ref(`${Config.userLikes}/${targetUid}`).update({ [myUid]: true });
            await db.ref(`users/${targetUid}`).update({ noOfLikes: ServerValue.increment(1) });
        } else {
            // deleted
            await db.ref(`${Config.userLikes}/${targetUid}/${myUid}`).remove();
            await db.ref(`users/${targetUid}`).update({ noOfLikes: ServerValue.increment(-1) });
        }
    },
);

/**
 * User mirror
 */
export const userMirror = onValueWritten(
    `${Config.users}/{uid}`,
    async (event): Promise<any> => {
        const firestore = getFirestore();
        const userUid = event.params.uid;

        if (event.data.before.exists()) {
            // updated
            const userData = event.data.after.val();
            // noOfLikes 는 자주 업데이트 되므로, firestore /users 를 목록 할 때, FirestoreListView 등에서 flickering 이 발생한다.
            // 그래서, noOfLikes 필드는 삭제한다.
            delete userData.noOfLikes;
            return await firestore.collection(Config.users).doc(userUid).update({ ...userData });
        }
        if (!event.data.after.exists()) {
            // deleted
            return await firestore.collection(Config.users).doc(userUid).delete();
        }
        // created
        return await firestore.collection(Config.users).doc(userUid).set(event.data.before.val());
    }
);

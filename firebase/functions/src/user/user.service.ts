import { getDatabase } from "firebase-admin/database";
import { Config } from "../config";
import { DeleteAccountResponse, User, UserCreateWithPhoneNumber } from "./user.interface";
import { getAuth } from "firebase-admin/auth";


/**
 * UserService
 */
export class UserService {
    /**
     * Get user data
     *
     * @param uid uid of the user
     * @returns the promise of the user data
     */
    static async get(uid: string): Promise<User> {
        const db = getDatabase();
        const data = (await db.ref(`${Config.users}/${uid}`).get()).val();
        return data as User;
    }

    /**
     * Create account with phone number
     *
     * @param params phone number
     * @returns the promise of the uid
     */
    static async createAccountWithPhoneNumber(params: UserCreateWithPhoneNumber): Promise<{
        code?: string,
        message?: string,
        uid?: string,
        customToken?: string,
        phoneNumber?: string
    }> {
        const auth = getAuth();
        try {
            const userRecord = await auth.createUser({ phoneNumber: params.phoneNumber });
            const customToken = await auth.createCustomToken(userRecord.uid);
            return { uid: userRecord.uid, customToken };
        } catch (e) {
            if (e instanceof Error) {
                // eslint-disable-next-line @typescript-eslint/no-explicit-any
                if ((e as any).errorInfo.code) {
                    // eslint-disable-next-line @typescript-eslint/no-explicit-any
                    return { code: (e as any).errorInfo.code, message: (e as any).errorInfo.message, phoneNumber: params.phoneNumber };
                }
                return { code: e.name, message: e.message };
            } else {
                return { code: "unknown", message: "unknown error" };
            }
        }
    }


    /**
     * Deletes the user account from Firebase Auth
     *
     * It only deletes the user account from Firebase Auth. Deletion of user data from
     * Firestore or Realtime Database must be done in clientend.
     *
     * @param uid uid of the user
     *
     * @returns the promise of the result
     * - { code: "ok" } if the user account is deleted successfully
     * - { code: ...error code..., message: ...error message..., uid: uid } if the user account is not found
     */
    static async deleteAccount(inputUid?: string): Promise<DeleteAccountResponse> {
        if (!inputUid) {
            return { code: "no-uid", message: "Pass uid to delete an account.", uid: "" };
        }
        const uid = inputUid;
        // Delete user account
        const auth = getAuth();
        try {
            await auth.deleteUser(uid);
            return { code: "ok", uid: uid };


            // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (e: any) {
            if (e instanceof Error) {
                // eslint-disable-next-line @typescript-eslint/no-explicit-any
                if ((e as any).errorInfo.code) {
                    // eslint-disable-next-line @typescript-eslint/no-explicit-any
                    return { code: (e as any).errorInfo.code, message: (e as any).errorInfo.message, uid: uid };
                }
                return { code: e.name, message: e.message, uid: uid };
            } else {
                return { code: "unknown", message: `${e}`, uid: uid };
            }
        }
    }


    /**
     * Returns an array of user uids who have turned on the comment notification.
     *
     * 입력된 사용자 uid 들 중에서 코멘트 알림을 켜 놓은 사용자 uid 를 리턴한다. 새 코멘트 푸시 알림을 보낼 때 사용된다.
     *
     * @param uids user uids
     *
     * @returns an array of user uids who have turned on the comment notification.
     *
     * 참고로, Promise.all 을 사용하여 병렬로 처리하면, 더 빠르게 처리할 수 있다. 그러나 이 함수는 코멘트 알림을 보낼 때에만 사용되므로,
     * 많은 async/await 작업을 하지 않는다. 평균 4~5 개 정도로 예상된다. 그래서 병렬로 처리할 필요가 없다.
     *
     * @example 예제는 tests/user/UserService.filterUidsWithCommentNotification.spec.ts 를 참고한다.
     */
    static async filterUidsWithCommentNotification(uids: string[]): Promise<string[]> {
        const db = getDatabase();
        const filteredUids = [];
        for (const uid of uids) {
            const data = (await db.ref(`${Config.userSettings}/${uid}/commentNotification`).get()).val();
            if (data === true) {
                filteredUids.push(uid);
            }
        }
        return filteredUids;
    }
}

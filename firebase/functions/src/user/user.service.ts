import { getDatabase } from "firebase-admin/database";
import { Config } from "../config";
import { User, UserCreateWithPhoneNumber } from "./user.interface";

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

    static async createAccountWithPhoneNumber(params: UserCreateWithPhoneNumber): Promise<{ uid: string }> {

        if (params.phoneNumber === undefined) {
            throw new Error("phoneNumber is required");
        }
        else if (typeof params.phoneNumber !== "string") {
            throw new Error("phoneNumber must be a string");
        }
        else if (params.phoneNumber.length < 10) {
            throw new Error("phoneNumber must be at least 10 characters long");
        }
        else if (params.phoneNumber.length > 15) {
            throw new Error("phoneNumber must be at most 15 characters long");
        }

        return { uid: '... should be a uid....' };

    }
}

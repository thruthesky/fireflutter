import { getDatabase } from "firebase-admin/database";
import { Config } from "../config";
import { User } from "./user.interface";

export class UserService {
    static async get(uid: string): Promise<User> {
        const db = getDatabase();
        const data = (await db.ref(`${Config.users}/${uid}`).get()).val();
        return data as User;
    }
}
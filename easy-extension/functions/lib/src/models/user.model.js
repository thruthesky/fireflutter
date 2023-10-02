"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserModel = void 0;
const admin = __importStar(require("firebase-admin"));
const config_1 = require("../config");
/**
 * UserModel
 *
 * Manage user data
 */
class UserModel {
    /**
     *
     * @param uid user uid
     * @returns DocumentReference
     */
    static ref(uid) {
        return admin.firestore().collection(config_1.Config.userCollectionName).doc(uid);
    }
    /**
     *
     * @param uid uid
     * @returns Promise<{ ... }>
     */
    static async getDocument(uid) {
        const user = await admin.firestore().collection(config_1.Config.userCollectionName).doc(uid).get();
        return user.data();
    }
    /**
     * Get a user information by the field with value.
     */
    static async getBy(field, value) {
        if (field === 'uid') {
            return await admin.auth().getUser(value);
        }
        else if (field == 'email') {
            return await admin.auth().getUserByEmail(value);
        }
        else if (field == 'phoneNumber') {
            return await admin.auth().getUserByPhoneNumber(value);
        }
        else {
            throw new Error("get_user/invalid-field");
        }
    }
    /**
         *
         * @param {*} uid
         * @param {*} claims
         * @returns
         */
    static async setCustomClaims(uid, claims) {
        await admin.auth().setCustomUserClaims(uid, claims);
        return uid;
    }
    /**
         *
         * @param {*} uid
         * @returns
         */
    static async getCustomClaims(uid) {
        const user = await admin.auth().getUser(uid);
        return user.customClaims;
    }
    /**
     *
     * @param uid user uid
     * @param claims claims to update
     * @returns Promise<void>
     */
    static async updateCustomClaims(uid, claims) {
        return await admin.auth().setCustomUserClaims(uid, Object.assign(Object.assign({}, ((await this.getCustomClaims(uid)) || {})), claims));
    }
    /**
     * Disable a user
     */
    static async disable(uid) {
        await admin.auth().updateUser(uid, { disabled: true });
    }
    /**
     * Enable a user from Firebase Auth
     */
    static async enable(uid) {
        await admin.auth().updateUser(uid, { disabled: false });
    }
    /**
     * Update user document with data.
     */
    static async update(uid, data) {
        await admin.firestore().collection(config_1.Config.userCollectionName).doc(uid).set(data, { merge: true });
    }
    /**
     * Delete a user account from Firebase Auth
     */
    static async delete(uid) {
        await admin.auth().deleteUser(uid);
    }
    /**
     * Popuplates possible user fields from user record.
     *
     * @param user user record
     * @returns map of user fields
     */
    static popuplateUserFields(user) {
        const doc = {};
        for (const field of ['uid', 'email', 'emailVerified', 'phoneNumber', 'displayName', 'photoURL', 'disabled', 'creationTime']) {
            const fieldValue = user[field];
            if (fieldValue) {
                doc[field] = fieldValue;
            }
        }
        return doc;
    }
    ;
    /**
     * Create a user document.
     *
     */
    static async createDocument(uid, data) {
        const ref = UserModel.ref(uid);
        return await ref.set(data);
    }
    static async deleteDocument(uid) {
        const ref = UserModel.ref(uid);
        return await ref.delete();
    }
    static async sync(snapshot) {
        //
        const user = snapshot.data();
        const uid = snapshot.id;
        const fields = config_1.Config.userSyncFields.split(",").map((field) => field.trim());
        const data = {};
        //
        for (const field of fields) {
            if (user[field] !== void 0) {
                data[field] = user[field];
            }
        }
        data['uid'] = uid;
        // has photo url?
        if (data['photoUrl'] !== void 0 && data['photoUrl'] !== null && data['photoUrl'] !== '') {
            data['hasPhotoUrl'] = true;
        }
        else {
            data['hasPhotoUrl'] = false;
        }
        //
        // sync to user_search_data and users
        await Promise.all([
            admin.firestore().collection('user_search_data').doc(uid).set(data),
            admin.database().ref(`users/${uid}`).set(data),
        ]);
    }
    static async deleteSync(uid) {
        await admin.firestore().collection('user_search_data').doc(uid).delete();
        await admin.database().ref(`users/${uid}`).remove();
    }
}
exports.UserModel = UserModel;
//# sourceMappingURL=user.model.js.map
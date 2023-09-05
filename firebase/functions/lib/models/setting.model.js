"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Setting = void 0;
const admin = require("firebase-admin");
/**
 * User class
 *
 * It supports user management for cloud functions.
 */
class Setting {
    static get counters() {
        return admin.firestore().collection("settings").doc("counters");
    }
    /**
     * update noOfUsers field in the document of /settings/counters in firestore
     * @return promise of write result
     */
    static increaseNoOfUsers() {
        return this.counters.set({
            noOfUsers: admin.firestore.FieldValue.increment(1),
        }, { merge: true });
    }
    /**
     * update noOfPosts field in the document of /settings/counters in firestore
     * @return promise of write result
     */
    static increaseNoOfPosts() {
        return this.counters.set({
            noOfPosts: admin.firestore.FieldValue.increment(1),
        }, { merge: true });
    }
    static increaseNoOfComments() {
        return this.counters.set({
            noOfComments: admin.firestore.FieldValue.increment(1),
        }, { merge: true });
    }
    static async getSystemSettings() {
        const data = await admin
            .firestore()
            .collection("settings")
            .doc("system")
            .get();
        return data.data();
    }
}
exports.Setting = Setting;
//# sourceMappingURL=setting.model.js.map
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Ref = void 0;
const admin = require("firebase-admin");
class Ref {
    static get auth() {
        return admin.auth();
    }
    static get db() {
        return admin.firestore();
    }
    static get rdb() {
        return admin.database();
    }
    static get settingsCol() {
        return this.db.collection("settings");
    }
    static get adminDoc() {
        return this.settingsCol.doc("admins");
    }
    static get users() {
        return this.db.collection("users");
    }
    static userDoc(uid) {
        return this.users.doc(uid);
    }
    static userSettings(uid) {
        return this.users.doc(uid).collection("user_settings");
    }
    static userSettingDoc(uid, docId) {
        return this.userSettings(uid).doc(docId);
    }
    static usersSettingsSearch(action, categoryId) {
        return this.db.collectionGroup("user_settings").where("action", "==", action)
            .where("categoryId", "==", categoryId);
    }
    static get usersPublicDataCol() {
        return this.db.collection("users_public_data");
    }
    // Returns user public data document path
    static publicDoc(uid) {
        return this.usersPublicDataCol.doc(uid);
    }
    static get categoryCol() {
        return this.db.collection("categories");
    }
    /**
     * Returns category referrence
     *
     * @param {*} id Category id
     * @return reference
     */
    static categoryDoc(id) {
        return this.categoryCol.doc(id);
    }
    static get postCol() {
        return this.db.collection("posts");
    }
    /**
     * Returns post reference
     * @param id post id
     * @return reference
     */
    static postDoc(id) {
        return this.postCol.doc(id);
    }
    static get commentCol() {
        return this.db.collection("comments");
    }
    static commentDoc(commentId) {
        return this.commentCol.doc(commentId);
    }
    static get chatRoomsCol() {
        return this.db.collection("chat_rooms");
    }
    static chatRoomsDoc(docId) {
        return this.chatRoomsCol.doc(docId);
    }
    static chatRoomDoc(docId) {
        return this.chatRoomsDoc(docId);
    }
    static get chatRoomMessagesCol() {
        return this.db.collection("chat_room_messages");
    }
    /** *************** MESSAGING References **************/
    static get tokenCollectionGroup() {
        return Ref.db.collectionGroup("fcm_tokens");
    }
    static tokenCol(uid) {
        return this.userDoc(uid).collection("fcm_tokens");
    }
    static tokenDoc(uid, token) {
        return this.tokenCol(uid).doc(token);
    }
    /** Point */
    static pointHistoryCol(uid) {
        return this.userDoc(uid).collection("point_history");
    }
    // Point history folder for post point events.
    static pointLastHistory(uid, eventName) {
        // console.log(this.pointHistoryCol(uid).path, eventName);
        return this.pointHistoryCol(uid)
            .where("eventName", "==", eventName)
            .orderBy("createdAt", "desc")
            .limit(1);
    }
}
exports.Ref = Ref;
//# sourceMappingURL=ref.js.map
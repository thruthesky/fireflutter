"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Chat = void 0;
const ref_1 = require("../utils/ref");
/**
 * User class
 *
 * It supports user management for cloud functions.
 */
class Chat {
    /**
     *
     * @param chatId
     * @returns
     */
    static async getRoom(chatId) {
        const data = await ref_1.Ref.chatDoc(chatId).get();
        return data.data();
    }
    /**
     * 채팅 메시지를 받아서, 채팅방 정보를 보고, 현재 메시지를 보낸 사용자를 제외한 나머지 사용자들의 UID 를 리턴한다.
     * 이 때, 채팅방 푸시 알림을 Disable(Off) 한 사용자는 빼고 메시지를 전달한다.
     * @param data chat room message document
     * @return array of other user uids
     */
    static async getOtherUserUidsFromChatMessageDocument(data) {
        const chatDoc = await ref_1.Ref.chatDoc(data.roomId).get();
        const chatData = chatDoc.data();
        // get uids
        let uids = chatData.users;
        // remove my uid
        uids = uids.filter((uid) => uid !== data.uid);
        // remove blocked users
        if (chatData.blockedUsers != null) {
            return uids.filter((uid) => !chatData.blockedUsers.includes(uid));
        }
        return uids;
    }
}
exports.Chat = Chat;
//# sourceMappingURL=chat.model.js.map
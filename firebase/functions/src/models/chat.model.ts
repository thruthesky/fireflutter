import {
  ChatDocument,
  ChatMessageDocument,
} from "../interfaces/chat.interface";
import { Ref } from "../utils/ref";

/**
 * User class
 *
 * It supports user management for cloud functions.
 */
export class Chat {
  /**
   *
   * @param chatId
   * @returns
   */
  static async getRoom(chatId: string): Promise<ChatDocument> {
    const data = await Ref.chatDoc(chatId).get();
    return data.data() as ChatDocument;
  }


  /**
   * 채팅 메시지를 받아서, 채팅방 정보를 보고, 현재 메시지를 보낸 사용자를 제외한 나머지 사용자들의 UID 를 리턴한다.
   * 이 때, 채팅방 푸시 알림을 Disable(Off) 한 사용자는 빼고 메시지를 전달한다.
   * @param data chat room message document
   * @return array of other user uids
   */
  static async getOtherUserUidsFromChatMessageDocument(
    data: ChatMessageDocument
  ): Promise<string[]> {
    const chatDoc = await Ref.chatDoc(data.roomId).get();
    const chatData = chatDoc.data() as ChatDocument;

    // get uids
    let uids: string[] = chatData.users;

    // remove my uid
    uids = uids.filter(
      (uid) => uid !== data.uid
    );

    // remove blocked users
    if (chatData.blockedUsers != null) {
      return uids.filter(
        (uid) => !chatData.blockedUsers.includes(uid)
      );
    }


    return uids;
  }
}

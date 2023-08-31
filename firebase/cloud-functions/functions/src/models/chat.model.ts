import * as admin from "firebase-admin";
import {
  ChatMessageDocument,
  ChatRoomDocument,
} from "../interfaces/chat.interface";
import {Ref} from "../utils/ref";
import {Setting} from "./setting.model";

/**
 * User class
 *
 * It supports user management for cloud functions.
 */
export class Chat {
  /**
   *
   * @param roomId
   * @returns
   */
  static async getRoom(roomId: string): Promise<ChatRoomDocument> {
    const data = await Ref.chatRoomsDoc(roomId).get();
    return data.data() as ChatRoomDocument;
  }

  /**
   * Save chat room settings
   *
   *
   * @param data
   *
   * 참고, 채팅방 정보 문서(/chat_rooms/<docId>)는 사용자가 채팅방에 입장 할 때,
   *  ChatRoomMessages 위젯에서 생성된다.
   * 그래서, 여기서 따로 채팅방이 존재하는지 하지 않는지 확인 할 필요 없다.
   *
   * 채팅 방의 사용자 추가, 삭제는 클라이언트에서 이루어져야 한다.
   */
  static async updateRoom(
    data: ChatMessageDocument
  ): Promise<admin.firestore.WriteResult> {
    // 채팅방 정보 업데이트
    const info: ChatRoomDocument = {
      last_message: data.text,
      last_message_timestamp: data.timestamp,
      last_message_sent_by: data.senderUserDocumentReference,
      last_message_seen_by: [data.senderUserDocumentReference],
    } as ChatRoomDocument;
    return data.chatRoomDocumentReference.set(info, {merge: true});
  }

  /**
   * 가입한 사용자에게 welcome 메시지를 보낸다.
   * @param uid 가입한 사용자 UID
   *
   * @return 웰컴 메시지를 전송했으면, 채팅방 ID를 반환한다. 아니면 null.
   */
  static async sendWelcomeMessage(uid: string): Promise<string | null> {
    const system = await Setting.getSystemSettings();
    if (system.helperUid && system.welcomeMessage) {
      const chatRoomId = [system.helperUid, uid].sort().join("-");

      // 웰컴 메시지를 채팅방 메세지로 기록
      const message: ChatMessageDocument = {
        chatRoomDocumentReference: Ref.chatRoomsCol.doc(chatRoomId),
        senderUserDocumentReference: Ref.userDoc(system.helperUid),
        text: system.welcomeMessage,
        timestamp: admin.firestore.Timestamp.now(),
      };
      await Ref.chatRoomMessagesCol.add(message);

      // * 사용자가 가입하면 웰컴 메시지를 보내는 경우에는, 채팅방을 생성해야 새 메시지 수 (1) 이 사용자 화면에 표시된다.
      // * 그래서 set(merge: true) 로 채팅방을 업데이트 하는 것이다.
      // *
      // await this.updateRoom(message);
      // 채팅방 정보 업데이트
      const info: ChatRoomDocument = {
        last_message: message.text,
        last_message_timestamp: message.timestamp,
        last_message_sent_by: message.senderUserDocumentReference,
        last_message_seen_by: [message.senderUserDocumentReference],
        users: [message.senderUserDocumentReference, Ref.userDoc(uid)],
      } as ChatRoomDocument;
      // 1:1 채팅이면, users 배열 추가.
      await message.chatRoomDocumentReference.set(info, {merge: true});

      return chatRoomId;
    } else {
      return null;
    }
  }

  /**
   * 채팅 메시지를 받아서, 채팅방 정보를 보고, 현재 메시지를 보낸 사용자를 제외한 나머지 사용자들의 UID 를 리턴한다.
   * 이 때, 채팅방 푸시 알림을 Disable(Off) 한 사용자는 빼고 메시지를 전달한다.
   * @param data chat room message document
   * @return array of other user uids
   */
  static async getOtherUserUidsFromChatMessageDocument(
    data: ChatMessageDocument
  ): Promise<string> {
    const chatRoomDoc = await data.chatRoomDocumentReference.get();
    const chatRoomData = chatRoomDoc.data() as ChatRoomDocument;

    // get uids
    const uids = chatRoomData.users.map((ref) => ref.id);

    // remove my uid
    const uidsExceptMe = uids.filter(
      (uid) => uid !== data.senderUserDocumentReference.id
    );

    // get uids of disabled users
    const uidsOfDisabledUsers = chatRoomData.notificationDisabledUsers.map(
      (ref) => ref.id
    );

    // remove disabled users
    const userUids = uidsExceptMe.filter(
      (uid) => !uidsOfDisabledUsers.includes(uid)
    );

    return userUids.join(",");
  }
}

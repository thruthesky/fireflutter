import * as admin from "firebase-admin";

export interface ChatMessageDocument {
  chatRoomDocumentReference: admin.firestore.DocumentReference;
  senderUserDocumentReference: admin.firestore.DocumentReference;
  text: string;
  timestamp: admin.firestore.Timestamp;
  photo_url?: string;
}

export interface ChatRoomDocument {
  last_message: string;
  last_message_seen_by: Array<admin.firestore.DocumentReference>;
  last_message_sent_by: admin.firestore.DocumentReference;
  last_message_timestamp: admin.firestore.Timestamp;
  users: Array<admin.firestore.DocumentReference>;
  notificationDisabledUsers: Array<admin.firestore.DocumentReference>;
}



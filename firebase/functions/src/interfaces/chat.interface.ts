import * as admin from "firebase-admin";

export interface ChatMessageDocument {
  roomId: string;
  text?: string;
  url?: string;
  protocol?: string;
  uid: string;
  createdAt: admin.firestore.Timestamp;
}


export interface ChatDocument {
  roodId: string;
  name: string;
  rename: Map<string, string>;
  group: string;
  open: string;
  master: string;
  users: string[];
  moderators: string[];
  blockedUsers: string[];
  createdAt: string;
  lastMessage: Map<string, string>;
}



import * as admin from "firebase-admin";

export interface PointHistory {
  eventName: string;
  point: number;
  createdAt: admin.firestore.Timestamp;
}

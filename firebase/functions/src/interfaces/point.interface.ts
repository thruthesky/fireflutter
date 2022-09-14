import * as admin from "firebase-admin";
import { EventName } from "../event-name";

export interface PointHistory {
  eventName: string;
  point: number;
  createdAt: admin.firestore.Timestamp;
}

export const pointEvent = {
  // / When user registers, he gets random points between 1000 and 2000.
  //   [EventName.register]: {
  //     point: 2000,
  //   },

  [EventName.postCreate]: {
    // point: 155,
    within: 60 * 60, // an hour
  },
  [EventName.commentCreate]: {
    // point: 88,
    within: 25 * 60, // 25 minutes
  },
};

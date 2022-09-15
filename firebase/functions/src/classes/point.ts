import * as admin from "firebase-admin";
// import * as functions from "firebase-functions";
import { Ref } from "../utils/ref";

import { PointHistory } from "../interfaces/point.interface";
import { Category } from "./category";
import { Utils } from "../utils/utils";
import { PostDocument } from "../interfaces/post.interface";
import { EventName } from "../event-name";
import { CommentDocument } from "../interfaces/comment.interface";
import { Config } from "../config";

/**
 * Point increase time duration.
 *
 * Point is not being increase every time on the action (post create or comment)
 * since there will be users who will abuse to get more points. The time on
 * [pointEvent.within] must be pass for users to get another point.
 *
 * The default maximum point of post create is "pointEvent[EventName.postCreate].point"
 * And the default maximum point of comment create is
 * "pointEvent[EventName.commentCreate].point".
 *
 * The amont of the point increasement is vary on every action. But admin can set
 * the maximum point increasement for each category. This means, each category
 * may have different amount of point increasement and event admin can set 0 point
 * increasement on a category.
 *
 * Note, for registration and sign-in bonus, see the code of old fireflutter version at
 * https://github.com/thruthesky/fireflutter_2022_09_02/blob/main/firebase/functions/src/classes/point.ts
 *
 */

export class Point {
  /**
   * Returns point document reference
   * @param data is the data of post
   * @param postId the post id that had just been created.
   * @returns reference of the point history document or null if the point event didn't happen.
   * @reference see `tests/point/list.ts` for generating post creation bonus point for test.
   */
  static async postCreate(data: PostDocument, postId: string) {
    // functions.logger.log("Point.postCreate() begins: data, postId:", data, postId);
    if (!data) throw Error("data is empty on Point.postCreate");
    if (!data.category) throw Error("data.category is empty on Point.postCreate");
    if (!postId) throw Error("postId is empty on Point.postCreate");

    if ((await this.timePassed(data.uid, EventName.postCreate)) === false) {
      // functions.logger.log("Point.postCreate() timePassed === false. Just return.");
      return null;
    }

    // Point history document to add into point history collection.
    const doc = await this.getCompleteData(data, EventName.postCreate);
    if (doc === null) {
      // functions.logger.log("Point.postCreate() getCompleteData() returns null. Just return.");
      return null;
    }

    // functions.logger.log("Point.postCreate() recording: doc:", doc);

    return Promise.all([
      this.updatePoint(data.uid, doc.point),
      Ref.pointHistoryCol(data.uid).add(doc),
      Ref.postDoc(postId).update({ point: doc.point }),
    ]);
  }

  static async commentCreate(data: CommentDocument, commentId: string) {
    if (!data) throw Error("data is empty on Point.commentCreate");
    if ((await this.timePassed(data.uid, EventName.commentCreate)) === false) return null;

    // Point document to add into point folder.
    const doc = await this.getCompleteData(data, EventName.commentCreate);
    if (doc === null) return;

    return Promise.all([
      this.updatePoint(data.uid, doc.point),
      Ref.pointHistoryCol(data.uid).add(doc),
      Ref.commentDoc(commentId).update({ point: doc.point }),
    ]);
  }

  static async updatePoint(uid: string, point: number): Promise<admin.firestore.WriteResult> {
    return Ref.userMetaPointDoc(uid).set(
        {
          point: admin.firestore.FieldValue.increment(point),
        },
        { merge: true }
    );
  }

  /**
   * Returns an object to save it as a point history.
   * @param data data of post or comment.
   * @param eventName point event name. it may be 'post-create' or 'comment-create'.
   * @returns return an object to be saved as point history.
   */
  static async getCompleteData(
      data: any,
      eventName: string
  ): Promise<{ eventName: string; createdAt: admin.firestore.FieldValue; point: number } | null> {
    let point = Config.maximumCommentCreationPoint;

    // functions.logger.log("getCompleteData() data:", data);
    if (eventName == EventName.postCreate) {
      const category = await Category.get(data.category);
      if (category === null) {
        throw Error("category is null(not exists) on Point.getCompleteData()");
      }

      if (!category.point) {
        // functions.logger.log("getCompleteData() category.point is empty: category:", category);
        return null;
      }

      // functions.logger.log("getCompleteData() got category:", category);
      point = category.point ?? 0;
    }

    return {
      eventName: eventName,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      point: this.getRandomPoint(point),
    };
  }

  /**
   * Returns random point of the point event. The minimum point is 1.
   * @param point Point event name
   */
  static getRandomPoint(point: number): number {
    return Utils.getRandomInt(1, point);
  }

  /**
   * Returns true if time has passed.
   *
   * Point histories are saved on realtime database.
   *
   * @param {*} ref folder reference of event history.
   * @param {*} eventName event name
   */
  static async timePassed(
      uid: string,
      // createdAt: admin.firestore.Timestamp,
      eventName: string
  ): Promise<boolean> {
    const within = Config.pointEvent[eventName].within;

    const deadline = new admin.firestore.Timestamp(Utils.getTimestamp() - within, 0);

    // functions.logger.log("timePassed(). deadline:", deadline);

    // Time didn't passed from last bonus point event? then don't do point event.
    const lastDoc = await this.getLastDoc(uid, eventName);

    if (lastDoc === null) {
      // functions.logger.log("timePassed(). lastDoc is null. So, return true.");
      return true;
    }

    // functions.logger.log("lastDoc.createdAt:", lastDoc.createdAt);

    // Time has passed?
    if (lastDoc.createdAt < deadline) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * Get last history of an event name
   */
  static async getLastDoc(uid: string, eventName: string): Promise<PointHistory | null> {
    const snapshot = await Ref.pointLastHistory(uid, eventName).get();

    if (snapshot.empty) return null;
    if (snapshot.size == 0) return null;
    return snapshot.docs[0].data() as unknown as PointHistory;
  }
}

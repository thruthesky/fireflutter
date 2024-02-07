import { onValueWritten } from "firebase-functions/v2/database";
import { Config } from "../config";
import { ServerValue, getDatabase } from "firebase-admin/database";

/**
 * managePostsAllSummary
 *
 * This function is triggered when a new post(post summary) is created/updated/deleted in the path under `/posts-summary` in RTDB.
 *
 */
export const userLike = onValueWritten(
    `${Config.userLikes}/{targetUid}/{myUid}`,
   async (event) => {
        const db = getDatabase();
        const myUid = event.params.myUid;
        const targetUid = event.params.targetUid;

        if (event.data.before.exists()) {
            // Update comes here
          return null;
        }

        if (!event.data.after.exists()) {
            // Data deleted
           await db.ref(`${Config.userWhoILike}/${myUid}`).update({[targetUid]: null });
           return db.ref(`users/${targetUid}`).update({noOfLikes: ServerValue.increment(-1)});
        }

        // Data has created
        await db.ref(`${Config.userWhoILike}/${myUid}`).update({[targetUid]: true });
        return db.ref(`users/${targetUid}`).update({noOfLikes: ServerValue.increment(1)});
    },
);



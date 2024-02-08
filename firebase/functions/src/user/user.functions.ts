import { onValueCreated, onValueDeleted } from "firebase-functions/v2/database";
import { Config } from "../config";
import { ServerValue, getDatabase } from "firebase-admin/database";
import { logger } from "firebase-functions/v1";

/**
 * User likes
 *
 */
export const userLikeCreated = onValueCreated(
    `${Config.userLikes}/{targetUid}/{myUid}`,
   async (event) => {
        const db = getDatabase();
        const myUid = event.params.myUid;
        const targetUid = event.params.targetUid;

        logger.info("userLike - Data created.");

        await db.ref(`${Config.userWhoILike}/${myUid}`).update({ [targetUid]: true });
        return db.ref(`users/${targetUid}`).update({ noOfLikes: ServerValue.increment(1) });
    },
);


/**
 * User unlikes
 *
 */
export const userLikeDeleted = onValueDeleted(
    `${Config.userLikes}/{targetUid}/{myUid}`,
   async (event) => {
        const db = getDatabase();
        const myUid = event.params.myUid;
        const targetUid = event.params.targetUid;

        logger.info("userLikeDeleted - Data deleted.", targetUid, myUid);

        await db.ref(`${Config.userWhoILike}/${myUid}/${targetUid}`).remove();
        return db.ref(`users/${targetUid}`).update({ noOfLikes: ServerValue.increment(-1) });
    },
);



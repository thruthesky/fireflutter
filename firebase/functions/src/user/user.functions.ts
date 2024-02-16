import { onValueCreated, onValueDeleted, onValueUpdated, onValueWritten } from "firebase-functions/v2/database";
import { Config } from "../config";
import { ServerValue, getDatabase } from "firebase-admin/database";
import { logger } from "firebase-functions/v1";
import { getFirestore } from "firebase-admin/firestore";



/**
 * Indexing for comments
 */
export const typesenseCommentIndexing = onValueWritten(
    `${Config.userWhoILike}/{myUid}/{targetUid}`,
    async (event): Promise<void> => {
        const db = getDatabase();
        const myUid = event.params.myUid;
        const targetUid = event.params.targetUid;

        // created or updated
        if (event.data.after.exists()) {
            await db.ref(`${Config.userLikes}/${targetUid}`).update({ [myUid]: true });
            await db.ref(`users/${targetUid}`).update({ noOfLikes: ServerValue.increment(1) });
        }

        else {
            // deleted
            await db.ref(`${Config.userLikes}/${targetUid}/${myUid}`).remove();
            await db.ref(`users/${targetUid}`).update({ noOfLikes: ServerValue.increment(-1) });
        }

    },
);




/**
 * User likes
 *
 */
export const userLikeCreated = onValueCreated(
    `${Config.userWhoILike}/{myUid}/{targetUid}`,
    async (event): Promise<void> => {
        const db = getDatabase();
        const myUid = event.params.myUid;
        const targetUid = event.params.targetUid;

        logger.info("userLike - Data created.");

        await db.ref(`${Config.userLikes}/${targetUid}`).update({ [myUid]: true });
        await db.ref(`users/${targetUid}`).update({ noOfLikes: ServerValue.increment(1) });
        return;
    },
);


/**
 * User unlikes
 *
 */
export const userLikeDeleted = onValueDeleted(
    `${Config.userWhoILike}/{myUid}/{targetUid}`,
    async (event): Promise<void> => {
        const db = getDatabase();
        const myUid = event.params.myUid;
        const targetUid = event.params.targetUid;

        logger.info("userLikeDeleted - Data deleted.", targetUid, myUid);

        await db.ref(`${Config.userLikes}/${targetUid}/${myUid}`).remove();
        await db.ref(`users/${targetUid}`).update({ noOfLikes: ServerValue.increment(-1) });
        return;
    },
);

/**
 * User Created
 *
 */
export const userToFirestoreCreated = onValueCreated(
    `${Config.users}/{uid}`,
    async (event) => {
        const firestore = getFirestore();
        const userUid = event.params.uid;
        // get the data
        const userData = event.data.val();
        logger.info("created Data", userData);
        // crate the firestore to collection with the data from the database
        return await firestore.collection(Config.users).doc(userUid).set(userData);
    }
);

/**
 * User Deleted
 *
 */
export const userToFirestoreUpdated = onValueUpdated(
    `${Config.users}/{uid}`,
    async (event) => {
        const db = getFirestore();
        const userUid = event.params.uid;
        const ref = db.collection(Config.users).doc(userUid);
        const userData = event.data.after.val();
        logger.info("updated Data", userData);

        // Remove noOfLikes from the user data for mirroing to firestore
        // because it may changes often and it would cause flickering on
        // the client side when it list the users.
        delete userData.noOfLikes;
        return await ref.update({ ...userData });
    }
);

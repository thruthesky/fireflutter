import { onValueWritten } from "firebase-functions/v2/database";
// import { Config } from "../config";
import { getFirestore } from "firebase-admin/firestore";
import { FirestoreComment, FirestorePost } from "./firestore.interface";


const Collections = {
    posts: "posts",
    comments: "comments",
};

/**
 * Post Mirror
 *
 * Mirror the post data to Firestore
 */
export const postMirror = onValueWritten(
    `${Collections.posts}/{category}/{postId}`,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    async (event): Promise<any> => {
        const firestore = getFirestore();
        const postId = event.params.postId;
        if (!event.data.after.exists()) {
            // Deleted
            return await firestore.collection(Collections.posts).doc(postId).delete();
        }
        // Created or Updated
        const data = event.data.after.val() as FirestorePost;
        data.category = event.params.category;
        return await firestore.collection(Collections.posts).doc(postId).set(data);
    }
);

/**
 * Comment Mirror
 *
 * Mirror the comment data to Firestore
 */
export const commentMirror = onValueWritten(
    `${Collections.comments}/{postId}/{commentId}`,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    async (event): Promise<any> => {
        const firestore = getFirestore();
        const postId = event.params.postId;
        const commentId = event.params.commentId;
        if (!event.data.after.exists() ) {
            // Deleted
            return await firestore.collection(Collections.comments).doc(commentId).delete();
        }
        // Created or Updated
        const data = event.data.after.val() as FirestoreComment;
        data.postId = postId;
        return await firestore.collection(Collections.comments).doc(commentId).set(data);
    }
);



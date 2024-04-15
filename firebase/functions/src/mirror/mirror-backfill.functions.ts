
import { getFirestore } from "firebase-admin/firestore";
import { getDatabase } from "firebase-admin/database";
import { onRequest } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v1";

/**
 * Mirror backfill users.
 *
 * Function to copy data from RTDB to Firestore with batched writes.
 *
 * This can be used to Mirror Users in RTDB
 * to Firestore for users that were not mirrored
 * before applying a user mirroring cloud functions.
 */
async function mirrorBackfillUsers(rtdbNode = "users", firestoreCollection = "users") {
  try {
    // Initialize Firestore and Realtime Database
    const firestore = getFirestore();
    const rtdb = getDatabase();
    // Retrieve data from RTDB
    const rtdbSnapshot = await rtdb.ref(rtdbNode).once("value");
    if (!rtdbSnapshot.exists()) {
      console.log("No users found in RTDB");
      return;
    }
    const rtdbData = rtdbSnapshot.val();
    console.log("Users RTDB Data:", rtdbData);
    // Initialize batch
    let batch = firestore.batch();
    let operationCount = 0;
    // Loop through each user in RTDB
    for (const userId of Object.keys(rtdbData)) {
      // Get user data
      const userData = rtdbData[userId];
      if (userData && userData.noOfLikes) {
        delete userData.noOfLikes;
      }
      if (userData && userData.displayName) {
        userData.searchDisplayName = userData.displayName.trim().toLowerCase().replace(/\s+/g, "");
      }
      // Add user data to batch
      const docRef = firestore.collection(firestoreCollection).doc(userId);
      batch.set(docRef, userData);
      operationCount++;
      // Before batch size reaches 500, commit the batch and reset
      if (operationCount == 498) {
        await batch.commit();
        batch = firestore.batch();
        operationCount = 0;
      }
    }
    // Commit any remaining operations
    if (operationCount > 0) {
      await batch.commit();
    }
    console.log("Users data copied successfully with batched writes!");
  } catch (error) {
    console.error("Error copying users data with batched writes:", error);
  }
}

/**
 * Mirror backfill posts.
 *
 * Function to copy data from RTDB to Firestore with batched writes.
 *
 * This can be used to Mirror Posts in RTDB
 * to Firestore for posts that were not mirrored
 * before applying a post mirroring cloud functions.
 */
async function mirrorBackfillPosts(rtdbNode = "posts", firestoreCollection = "posts") {
  try {
    // Initialize Firestore and Realtime Database
    const firestore = getFirestore();
    const rtdb = getDatabase();
    // Retrieve data from RTDB
    const rtdbSnapshot = await rtdb.ref(rtdbNode).once("value");
    if (!rtdbSnapshot.exists()) {
      console.log("No posts found in RTDB");
      return;
    }
    const categoriesData = rtdbSnapshot.val();
    console.log("Categories RTDB Data:", categoriesData);
    // Initialize batch
    let batch = firestore.batch();
    let operationCount = 0;
    // Loop through each category in RTDB
    console.log("categories data: ", categoriesData);
    for (const category of Object.keys(categoriesData)) {
      const postsData = categoriesData[category];
      // Loop through each post in the category
      for (const postId of Object.keys(postsData)) {
        const postData = postsData[postId];
        // Use postId as document ID
        const postDocRef = firestore.collection(firestoreCollection).doc(postId);
        console.log("Post Data being batch set: id: " + postId, postData);
        // Add post data to batch
        batch.set(postDocRef, {
          category: category,
          ...postData, // Spread the rest of the data
        });
        operationCount = operationCount + 1;
        // Before batch size reaches 500, commit the batch and reset
        if (operationCount == 498) {
          // ask for help here
          await batch.commit();
          batch = firestore.batch();
          operationCount = 0;
        }
      }
    }
    console.log("operation count: " + operationCount);
    // Commit any remaining operations
    if (operationCount > 0) {
      console.log("operationCount > 0");
      batch.commit().then(() => {
        console.log("Batch committed successfully!");
      });
    }
    console.log("Posts data copied successfully with batched writes!");
  } catch (error) {
    console.error("Error copying posts data with batched writes:", error);
  }
}


/**
 * Mirror backfill comments.
 *
 * Function to copy data from RTDB to Firestore with batched writes.
 *
 * This can be used to Mirror Posts in RTDB
 * to Firestore for posts that were not mirrored
 * before applying a post mirroring cloud functions.
 */
async function mirrorBackfillComments(rtdbNode = "comments", firestoreCollection = "comments") {
  try {
    // Initialize Firestore and Realtime Database
    const firestore = getFirestore();
    const rtdb = getDatabase();
    // Retrieve data from RTDB
    const rtdbSnapshot = await rtdb.ref(rtdbNode).once("value");
    if (!rtdbSnapshot.exists()) {
      console.log("No comments found in RTDB");
      return;
    }
    const commentsData = rtdbSnapshot.val();
    console.log("Comments RTDB Data:", commentsData);
    // Initialize batch
    let batch = firestore.batch();
    let operationCount = 0;
    // Loop through each postId in RTDB
    for (const postId of Object.keys(commentsData)) {
      const postCommentsData = commentsData[postId];
      // Loop through each comment under the postId
      for (const commentId of Object.keys(postCommentsData)) {
        const commentData = postCommentsData[commentId];
        // Add comment data to batch
        const newCommentRef = firestore.collection(firestoreCollection).doc(commentId);
        batch.set(newCommentRef, {
          postId: postId,
          ...commentData, // Spread the rest of the data
        });
        operationCount++;
        // Before batch size reaches 500, commit the batch and reset
        if (operationCount == 498) {
          await batch.commit();
          batch = firestore.batch();
          operationCount = 0;
        }
      }
    }
    // Commit any remaining operations
    if (operationCount > 0) {
      await batch.commit();
    }
    console.log("Comments data copied successfully with batched writes!");
  } catch (error) {
    console.error("Error copying comments data with batched writes:", error);
  }
}

export const mirrorBackfillRtdbToFirestore = onRequest(async (request, response)=>{
  try {
    await mirrorBackfillUsers();
    await mirrorBackfillPosts();
    await mirrorBackfillComments();
    response.writeHead(200, { "Content-Type": "text/html" });
    response.write("Mirrored backfill data from RTDB to Firestore successfully!");
  } catch (e) {
      logger.error(e);
      response.writeHead(500, { "Content-Type": "text/html" });
      if (e instanceof Error) {
          response.write(e.message);
      } else {
          response.write("unknown error");
      }
  } finally {
    response.end();
  }
});

/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { onDocumentCreated, FirestoreEvent } from "firebase-functions/v2/firestore";

import * as logger from "firebase-functions/logger";
import { QueryDocumentSnapshot } from "firebase-admin/firestore";

exports.uppercase = onDocumentCreated("my-collection/{docId}", (event: FirestoreEvent<QueryDocumentSnapshot | undefined>) => {
    /* ... */
    logger.info("Hello logs!", { structuredData: true });

    if (event === undefined || typeof event === 'undefined') {
        return;
    }

    return event.data?.ref.set({
        uppercase: event.data?.data().original.toUpperCase()
    });
});


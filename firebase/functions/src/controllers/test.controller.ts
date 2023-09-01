import {onDocumentCreated, FirestoreEvent}
  from "firebase-functions/v2/firestore";

import * as logger from "firebase-functions/logger";
import {QueryDocumentSnapshot} from "firebase-admin/firestore";


exports.uppercase = onDocumentCreated("my-collection/{docId}",
  (event: FirestoreEvent<QueryDocumentSnapshot | undefined>) => {
    /* ... */
    logger.info("Hello logs!", {structuredData: true});

    if (event === undefined || typeof event === "undefined") {
      return;
    }

    return event.data?.ref.update({
      doneAt: new Date(),
      uppercase: event.data?.data().original.toUpperCase(),
    });
  });





import { initializeApp } from "firebase-admin/app";
import { onValueWritten } from "firebase-functions/v2/database";
// import { setGlobalOptions } from "firebase-functions/v2/options";


// / initialize firebase app
initializeApp();

// setGlobalOptions({ region: "asia-northeast3" });

export * from "./messaging/messaging.functions";
export * from "./typesense/typesense.functions";


export const makeUppercase = onValueWritten("/messages/{pushId}/original", (event) => {
    // Only edit data when it is first created.
    if (event.data.before.exists()) {
        return null;
    }
    // Exit when the data is deleted.
    if (!event.data.after.exists()) {
        return null;
    }
    // Grab the current value of what was written to the Realtime Database.
    const original = event.data.after.val();
    console.log("Uppercasing", event.params.pushId, original);
    const uppercase = original.toUpperCase();
    // You must return a Promise when performing asynchronous tasks inside a Functions such as
    // writing to the Firebase Realtime Database.
    // Setting an "uppercase" sibling in the Realtime Database returns a Promise.
    return event.data.after.ref.parent?.child("uppercase").set(uppercase);
});

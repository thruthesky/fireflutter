import * as admin from "firebase-admin";


/**
 * Initialize the Firebase app with the database URL.
 */
export function firebaseWithcenterTest2OnlineInit() {
    if (admin.apps.length === 0) {
        admin.initializeApp({
            databaseURL: "https://withcenter-test-2-default-rtdb.asia-southeast1.firebasedatabase.app/",
        });
    }
}



import * as functions from "firebase-functions";
import * as express from "express";
import { initializeApp } from "firebase/app";
import { getFirestore, doc, getDoc, DocumentSnapshot } from "firebase/firestore";

// Initialize Express app
const app = express();
// Set up Firebase Cloud Function
export const link = functions.https.onRequest(app);

const firebaseConfig = {
    apiKey: "AIzaSyC8ME9ffn9KwEg01zrtzHgHdV80V0Qxj2c",
    authDomain: "withcenter-meetup-3.firebaseapp.com",
    databaseURL: "https://withcenter-meetup-3-default-rtdb.asia-southeast1.firebasedatabase.app",
    projectId: "withcenter-meetup-3",
    storageBucket: "withcenter-meetup-3.appspot.com",
    messagingSenderId: "103508765497",
    appId: "1:103508765497:web:64cbdcc1f57acf8ddad6e8",
  };

/**
 * Returns the Document Snapshot
 * @param docId
 */
async function getDeeplinkDoc( docId: string ): Promise<DocumentSnapshot> {
    const firebaseApp = initializeApp(firebaseConfig);
    const db = getFirestore(firebaseApp);
    const docRef = doc(db, "_deeplink_", docId);
    const docSnap = await getDoc(docRef);
    return docSnap;
}

app.get("/.well-known/apple-app-site-association", async (req, res) => {
    const docSnaphot = await getDeeplinkDoc("apple");
    res.writeHead(200, { "Content-Type": "application/json" });
    if (docSnaphot.exists()) {
        res.write(JSON.stringify(docSnaphot.data()["value"]));
    } else {
        // docSnap.data() will be undefined in this case
        res.write("Page not found!");
    }
    res.end();
});

app.get("/.well-known/assetlinks.json", async (req, res) => {
    const docSnaphot = await getDeeplinkDoc("android");
    res.writeHead(200, { "Content-Type": "application/json" });
    if (docSnaphot.exists()) {
        res.write(JSON.stringify(docSnaphot.data()["value"]));
    } else {
        // docSnap.data() will be undefined in this case
        res.write("Page not found!");
    }
    res.end();
});

app.get("*", async (req, res) => {
    const docSnaphot = await getDeeplinkDoc("html");
    if (docSnaphot.exists()) {
        const source = docSnaphot.data()["value"];
        // Return the webpage
        return res.send(source);
    }
    // Return the webpage
    return res.send("Page not found!");
});



import * as functions from "firebase-functions";
import * as express from "express";
import { getFirestore, doc, getDoc, DocumentSnapshot } from "firebase/firestore";
import { LinkCredential } from "./link.interface";

// Initialize Express app
const app = express();
// Set up Firebase Cloud Function
export const link = functions.https.onRequest(app);


/**
 * Returns the Document Snapshot
 * @param docId
 */
async function getDeeplinkDoc(docId: string): Promise<DocumentSnapshot> {
    const db = getFirestore();
    const docRef = doc(db, "_deeplink_", docId);
    const docSnap = await getDoc(docRef);
    return docSnap;
}

app.get("/.well-known/apple-app-site-association", async (req, res) => {
    const docSnaphot = await getDeeplinkDoc("apple");
    res.writeHead(200, { "Content-Type": "application/json" });
    if (docSnaphot.exists()) {
        const data = docSnaphot.data() as LinkCredential;

        res.write(JSON.stringify(data.value));
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
        res.write(JSON.stringify((docSnaphot.data() as LinkCredential).value));
    } else {
        // docSnap.data() will be undefined in this case
        res.write("Page not found!");
    }
    res.end();
});

app.get("*", async (req, res) => {
    const docSnaphot = await getDeeplinkDoc("html");
    if (docSnaphot.exists()) {
        const source = (docSnaphot.data() as LinkCredential).value;
        // Return the webpage
        return res.send(source);
    }
    // Return the webpage
    return res.send("Page not found!");
});

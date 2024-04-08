

import * as functions from "firebase-functions";
import * as express from "express";
// import { initializeApp } from "firebase/app";
import { getFirestore, doc, getDoc, DocumentSnapshot } from "firebase/firestore";
import { AndroidCredential, LinkCredential } from "./link.interface";

// Initialize Express app
const app = express();
// Set up Firebase Cloud Function
export const link = functions.https.onRequest(app);


/**
 * Returns the Document Snapshot
 * @param docId
 */
async function getDeeplinkDoc( docId: string ): Promise<DocumentSnapshot> {
    // const firebaseApp = initializeApp(firebaseConfig);
    // const db = getFirestore(firebaseApp);
    const db = getFirestore();
    const docRef = doc(db, "_deeplink_", docId);
    const docSnap = await getDoc(docRef);
    return docSnap;
}

app.get("/.well-known/apple-app-site-association", async (req, res) => {
    const docSnaphot = await getDeeplinkDoc("apple");
    res.writeHead(200, { "Content-Type": "application/json" });
    if (docSnaphot.exists()) {
        const snapshotData = docSnaphot.data();
        const applinkDetails = Object.entries(snapshotData).map(([teamId, appBundelId]) => ({
            appID: teamId + "." + appBundelId,
            paths: ["*"],
        }));
        const webCredentials = Object.entries(snapshotData).map(([teamId, appBundelId]) => (
            teamId + "." + appBundelId
        ));
        const appsSiteAssociation = {
            applinks: {
                details: applinkDetails,
            },
            webCredentials: {
                apps: webCredentials,
            },
        };
        res.write(JSON.stringify(appsSiteAssociation));
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
        const snapshotData: AndroidCredential = docSnaphot.data();
        const jsonCredentials = Object.entries(snapshotData).map(([appName, sha256s]) => ({
            relation: ["delegate_permission/common.handle_all_urls"],
            target: {
                namespace: "android_app",
                package_name: appName,
                sha256_cert_fingerprints: sha256s,
            },
        }));
        res.write(JSON.stringify(jsonCredentials));
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

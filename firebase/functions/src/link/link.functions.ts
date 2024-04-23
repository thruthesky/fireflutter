/* eslint-disable max-len */

import * as functions from "firebase-functions";
import * as express from "express";
import { getFirestore, DocumentSnapshot } from "firebase-admin/firestore";
import { AndroidCredential, AppleCredential } from "./link.interface";
import { DataSnapshot, getDatabase } from "firebase-admin/database";

// Initialize Express app
export const expressApp = express();

// Set up Firebase Cloud Function
export const link = functions.https.onRequest(expressApp);

/**
 * Returns the Document Snapshot
 * @param docId
 */
async function getDeeplinkDoc(docId: string): Promise<DocumentSnapshot> {
  const db = getFirestore();
  const docSnap = await db.collection("_link_").doc(docId).get();
  return docSnap;
}

/**
 * Returns the Data Snapshot
 * @param path
 */
async function getRtdbSnapshot(path: string): Promise<DataSnapshot> {
  const db = getDatabase();
  const docSnap = await db.ref(path).once("value");
  return docSnap;
}

/**
 * Returns the previews
 * @param pid
 * @param uid
 * @param cid
 * @returns
 */
async function getPreview(pid?: string, uid?: string, cid?: string): Promise<{ [key: string]: string }> {
  if (pid) return getPostPreview(pid);
  if (uid) return getUserPreview(uid);
  if (cid) return getChatPreview(cid);
  return {};
}

/**
 * Returns the previews for post
 * @param pid
 * @returns
 */
async function getPostPreview(pid: string): Promise<{ [key: string]: string }> {
  // TODO for confirmation:
  // In RTDB, the cost is based on the data transfered not per read.
  // In this code, the snapshot is getitng all the details under the post.
  // Will it be better if we get value one by one?
  const docSnap = await getRtdbSnapshot(`posts/${pid}/preview`);
  if (docSnap.exists()) {
    const post = docSnap.val();
    return {
      title: post.title,
      description: post.content,
      previewImageLink: post.url,
    };
  }
  return {};
}

/**
 * Returns the previews for user
 * @param uid
 */
async function getUserPreview(uid: string): Promise<{ [key: string]: string }> {
  const docSnap = await getRtdbSnapshot(`users/${uid}`);
  if (docSnap.exists()) {
    const user = docSnap.val();
    return {
      title: user.name,
      description: user.stateMessage,
      previewImageLink: user.photoUrl,
    };
  }
  return {};
}

/**
 * Returns the previews for Chat Room
 * @param cid
 * @returns
 */
async function getChatPreview(cid: string): Promise<{ [key: string]: string }> {
  const docSnap = await getRtdbSnapshot(`chat-rooms/${cid}`);
  if (docSnap.exists()) {
    const chatRoom = docSnap.val();
    return {
      title: chatRoom.name,
      description: chatRoom.description,
      previewImageLink: chatRoom.iconUrl,
    };
  }
  return {};
}

expressApp.get("/.well-known/apple-app-site-association", async (req, res) => {
  const docSnaphot = await getDeeplinkDoc("ios");
  res.writeHead(200, { "Content-Type": "application/json" });
  if (docSnaphot.exists) {
    const snapshotData: AppleCredential = docSnaphot.data() as AppleCredential;
    const applinkDetails = snapshotData.apps.map((teamIDAndAppIBundled) => ({
      appID: teamIDAndAppIBundled,
      paths: ["*"],
      // appIDs: [teamIDAndAppIBundled],
    }));
    const webCredentials = snapshotData.apps.map((teamIDAndAppIBundled) => (
      teamIDAndAppIBundled
    ));
    const appsSiteAssociation = {
      applinks: {
        // apps: [],
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

expressApp.get("/.well-known/assetlinks.json", async (req, res) => {
  const docSnaphot = await getDeeplinkDoc("android");
  res.writeHead(200, { "Content-Type": "application/json" });
  if (docSnaphot.exists) {
    const snapshotData: AndroidCredential = docSnaphot.data() as AndroidCredential;
    const jsonCredentials = Object.entries(snapshotData).map(([appName, sha256s]) => ({
      relation: ["delegate_permission/common.handle_all_urls"],
      target: {
        namespace: "android_app",
        package_name: appName,
        sha256_cert_fingerprints: sha256s.map((sha) => sha.toUpperCase()),
      },
    }));
    res.write(JSON.stringify(jsonCredentials));
  } else {
    // docSnap.data() will be undefined in this case
    res.write("Page not found!");
  }
  res.end();
});

const defaultHtml = `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <meta
    name="apple-itunes-app"
    content="app-id=#{{appleAppId}}, app-argument=#{{webUrl}}"
    />

    <link rel="icon" type="image/png" href="#{{appIconLink}}" />

    <meta name="application-name" content="#{{appName}}" />

    <title>#{{title}}</title>
    <meta name="description" content="#{{description}}" />

    <meta property="og:title" content="#{{title}}" />
    <meta property="og:description" content="#{{description}}" />
    <meta property="og:image" content="#{{previewImageLink}}" />
    <meta property="og:type" content="website" />
    <meta property="og:locale" content="en_US" />

    <meta name="twitter:card" content="#{{description}}" />
    <meta name="twitter:title" content="#{{title}}" />
    <meta name="twitter:site" content="#{{webUrl}}" />
    <meta name="twitter:description" content="#{{description}}" />
    <meta name="twitter:image" content="#{{previewImageLink}}" />
    
    <style>
      .centered {
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-family: Verdana, Geneva, Tahoma, sans-serif;
        color: black;
        font-size: x-large;
        text-align: center;
      }
      body {
        background-color: white;
      }
    </style>

    <script>
      var userAgent = window.navigator.userAgent;
      var os = '';
      
      if ( /iPhone/.test(userAgent) || /iPad/.test(userAgent) || /iPod/.test(userAgent) || ( /Mac/.test(userAgent)  && "ontouchend" in document)) {
        os = 'iOS';
      } else if (/Android/.test(userAgent)) {
        os = 'Android';
      } else {
        os = 'Desktop';
      }
    </script>
  </head>
  <body>
    <div class="centered">
      #{{redirectingMessage}}
    </div>
    <script>
    
      var webUrl = "#{{webUrl}}";
      var appStoreUrl = "#{{appStoreUrl}}";
      var playStoreUrl = "#{{playStoreUrl}}";
      
      console.log('--- detect os', os);

      if (os === "iOS") {
        alert(appStoreUrl);
        if ( appStoreUrl ) {
          window.location.replace(appStoreUrl);
        } else {
          alert("iOS URL is empty");
        }
      } else if ( os === "Android") {
        if ( playStoreUrl ) {
          window.location.replace(playStoreUrl);
        } else {
          alert("Android URL is empty");
        }
      } else if ( os === "Desktop" ) {
        if ( webUrl ) {
          window.location.replace(webUrl);
        }
        else {
          alert("Web URL is empty");
        }
      } else {
        alert("#{{redirectingErrorMessage}}");
      }
      
    </script>
  </body>
</html>`;


/**
 * This method is called on all access under `/link` url.
 */
expressApp.get("*", async (req, res) => {
  let htmlSource = defaultHtml;

  const snapshot = await getDeeplinkDoc("apps");
  if (!snapshot.exists) {
    return res.send("/_link_/app document not found! Please create one.");
  }

  // Prepare the content
  const appName = (req.query.appName ?? "") as string;

  // Post
  const pid = (req.query.pid ?? "") as string;
  // Chat Room
  const cid = (req.query.cid ?? "") as string;
  // User
  const uid = (req.query.uid ?? "") as string;

  // TODO For confirmation
  // const path = (req.query.path ?? "") as string;

  const map = snapshot.data() as { [key: string]: { [key: string]: string } };

  const previewDetails = await getPreview(pid, cid, uid);

  let appData: { [key: string]: string } = map["default"];

  if (appName && map[appName]) {
    appData = map[appName];
  }

  appData = {
    ...appData,
    ...previewDetails,
  };

  for (const key of Object.keys(appData)) {
    htmlSource = htmlSource.replaceAll(`#{{${key}}}`, appData[key]);
  }

  // Return the webpage
  return res.send(htmlSource);
});

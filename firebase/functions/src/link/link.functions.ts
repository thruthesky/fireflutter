

import * as functions from "firebase-functions";
import * as express from "express";
import { Config } from "../config";
import { initializeApp } from "firebase/app";
import { getFirestore, doc, getDoc } from "firebase/firestore";

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

app.get("/.well-known/apple-app-site-association", async (req, res) => {
    const firebaseApp = initializeApp(firebaseConfig);
    const db = getFirestore(firebaseApp);
    const docRef = doc(db, "_deeplink_", "apple");
    const docSnap = await getDoc(docRef);
    res.writeHead(200, { "Content-Type": "application/json" });
    if (docSnap.exists()) {
        console.log("Document data:", docSnap.data());
        res.write(JSON.stringify(docSnap.data()["value"]));
    } else {
        // docSnap.data() will be undefined in this case
        res.write(JSON.stringify({}));
        console.log("No such document!");
    }
    res.end();
});

app.get("/.well-known/assetlinks.json", (req, res) => {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.write(JSON.stringify(
        [{
            relation: [
                "delegate_permission/common.handle_all_urls",
            ],
            target: {
                namespace: "android_app",
                package_name: "com.withcenter.roha",
                sha256_cert_fingerprints: [
                    "2D:BD:C7:28:CF:1E:11:EA:87:D5:B8:2C:56:BB:F1:56:98:F4:C0:AB:88:8E:3A:47:BF:F0:A9:69:4C:22:BE:7E",
                ],
            },
        }]
    ));
    res.end();
});

app.get("*", (req, res, next) => {
    // Define values
    const title = "Roha";
    const subtitle = "Find out more about my app...";
    const image = "https://.../your-app-banner.jpg";

    const html = `
    <!DOCTYPE html>
    <html lang="en">
    
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="apple-itunes-app" content="app-id=myAppID, affiliate-data=myAffiliateData, app-argument=myURL">
    
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="white">
        <meta name="apple-mobile-web-app-title" content="My Awesome App">
        <meta name="apple-mobile-web-app-title" content="My Awesome App">
    
        <link rel="icon" type="image/png" href="...">
        <link rel="mask-icon" href="" color="#ffffff">
        <meta name="application-name" content="My Awesome App">
    
        <title>{{title}}</title>
        <meta name="description" content="{{subtitle}}" />
        <meta property="og:title" content="{{title}}" />
        <meta property="og:description" content="{{subtitle}}" />
        <meta property="og:image" content="{{imageUrl}}" />
        <meta property="og:type" content="website" />
        <meta property="og:locale" content="en_US" />
    
        <meta name="twitter:card" content="summary_large_image"></meta>
        <meta name="twitter:title" content="{{title}}"></meta>
        <meta name="twitter:site" content="myawesomeapp.com"></meta>
        <meta name="twitter:description" content="{{subtitle}}"></meta>
        <meta name="twitter:image" content="{{imageUrl}}"></meta>
    
        <link rel="apple-touch-icon" href="...">
    </head>
    
    <body>
        <!-- YOUR PAGE CONTENT HERE -->
        TEST New
        <script src="https://cdnjs.cloudflare.com/ajax/libs/Detect.js/2.2.2/detect.min.js" rossorigin="anonymous" referrerpolicy="no-referrer"></script>
        <script>
            // Optional: redirect users on mobile platforms to the according store
            var result = detect.parse(navigator.userAgent);
            if (result.os.family === 'iOS') {
                window.location.replace("https://apps.apple.com/us/app/{{iosLinkId}}");
            } else if (result.os.family.includes('Android')) {
                window.location.replace("https://play.google.com/store/apps/details?id={{androidBundleId}}");
            } else {
                // window.location.replace("yourwebsite link");
            }
        // You can handle any other logic here - Google Analytics, popups, etc...
        </script>
    </body>
    
</html>
`;
    // Replace handles with content
    const source = html
        .replaceAll("{{title}}", title)
        .replaceAll("{{subtitle}}", subtitle)
        .replaceAll("{{image}}", image)
        .replaceAll("{{androidBundleId}}", Config.androidBundleId)
        .replaceAll("{{iosLinkId}}", Config.iosLinkId);

    // Return the webpage
    return res.send(source);
});



import * as functions from "firebase-functions";
import * as express from "express";
import { Config } from "../config";


// Initialize Express app
const app = express();
// Set up Firebase Cloud Function
export const link = functions.https.onRequest(app);


app.get("/.well-known/apple-app-site-association", (req, res) => {
    const applicationID = `${Config.appleTeamId}.${Config.iosBundleId}`;

    res.writeHead(200, { "Content-Type": "application/json" });
    res.write(JSON.stringify({
        applinks: {
            apps: [],
            details: [{
                appID: applicationID,
                paths: [
                    "*",
                ],
            }],
        },
        webcredentials: {
            apps: [
                applicationID,
            ],
        },
    }));
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
                package_name: "YOUR_PACKAGE_NAME",
                sha256_cert_fingerprints: [
                    "YOUR_SHA256_FINGERPRINT",
                ],
            },
        }]
    ));
    res.end();
});


app.get("*", (req, res, next) => {
    // Define values
    const title = "My Amazing Application";
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
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Detect.js/2.2.2/detect.min.js" rossorigin="anonymous" referrerpolicy="no-referrer"></script>
    
    <body>
        <!-- YOUR PAGE CONTENT HERE -->
    </body>
    
    <script>
      // Optional: redirect users on mobile platforms to the according store
        var result = detect.parse(navigator.userAgent);
        if (result.os.family === 'iOS') {
            window.location.href = 'https://apps.apple.com/us/app/YOUR_APP_ID';
        } else if (result.os.family.includes('Android')) {
            window.location.href = 'https://play.google.com/store/apps/details?id=YOUR_APP_ID';
        } else {
            window.location.href = 'https://your-homepage.com/?path=menu
        }
      // You can handle any other logic here - Google Analytics, popups, etc...
    </script>
    </html>
`;
    // Replace handles with content
    const source = html
        .replaceAll("{{title}}", title)
        .replaceAll("{{subtitle}}", subtitle)
        .replaceAll("{{image}}", image);

    // Return the webpage
    return res.send(source);
});

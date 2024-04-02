

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
                package_name: "com.withcenter.roha",
                sha256_cert_fingerprints: [
                    "87:B4:AB:C6:F0:A9:AB:FC:94:54:C0:AA:A0:81:EC:99:F4:0B:F1:26:F2:1C:57:F0:E2:0D:9C:4D:45:C4:FB:35",
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
                window.location.replace("https://apps.apple.com/us/app/id6478899497");
            } else if (result.os.family.includes('Android')) {
                window.location.replace("https://play.google.com/store/apps/details?id=com.withcenter.roha");
            } else {
                // window.location.replace("https://play.google.com/store/apps/details?id=com.withcenter.roha");
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
        .replaceAll("{{image}}", image);

    // Return the webpage
    return res.send(source);
});

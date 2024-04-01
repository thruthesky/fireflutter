

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as express from 'express';
import * as fs from "fs";
import * as path from 'path';
import { Config } from "../config";




// Initialize Firebase Admin SDK
admin.initializeApp();
// Initialize Express app
const app = express();
// Set up Firebase Cloud Function
export const api = functions.https.onRequest(app);


app.get('*', (req, res, next) => {
    // Define values
    const title = 'My Amazing Application';
    const subtitle = 'Find out more about my app...';
    const image = 'https://.../your-app-banner.jpg';

    // Load HTML template
    const templatePath = path.join(__dirname, './assets/html/index.html');

    // Replace handles with content
    var source = fs.readFileSync(templatePath, { encoding: 'utf-8' })
        .replaceAll('{{title}}', title)
        .replaceAll('{{subtitle}}', subtitle)
        .replaceAll('{{image}}', image);

    // Return the webpage
    return res.send(source);
});




app.get('/.well-known/apple-app-site-association', (req, res) => {
    const applicationID = `${Config.appleTeamId}.${Config.iosBundleId}`
    // Example: FGSV552D.com.example.myawesomeapp

    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.write(JSON.stringify({
        "applinks": {
            "apps": [],
            "details": [{
                "appID": applicationID,
                "paths": [
                    "*",
                ],
            }]
        },
        "webcredentials": {
            "apps": [
                applicationID
            ]
        }
    }))
    res.end();
});

app.get('/.well-known/assetlinks.json', (req, res) => {
    res.writeHead(200, { 'Content-Type': 'application/json' })
    res.write(JSON.stringify(
        [{
            "relation": [
                "delegate_permission/common.handle_all_urls"
            ],
            "target": {
                "namespace": "android_app",
                "package_name": "YOUR_PACKAGE_NAME",
                "sha256_cert_fingerprints": [
                    "YOUR_SHA256_FINGERPRINT"
                ]
            }
        }]
    ))
    res.end();
});
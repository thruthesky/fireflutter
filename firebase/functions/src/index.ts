import * as admin from "firebase-admin";
// import * as functions from "firebase-functions";
// import { Point } from "./classes/point";

admin.initializeApp();

admin.firestore().settings({ ignoreUndefinedProperties: true });

export * from "./functions/user.functions";
export * from "./functions/messaging.functions";
export * from "./functions/point.functions";
export * from "./functions/test.functions";

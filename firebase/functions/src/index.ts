

import { initializeApp } from "firebase-admin/app";


// / initialize firebase app
initializeApp();

export * from "./messaging/messaging.functions";
export * from "./typesense/typesense.functions";



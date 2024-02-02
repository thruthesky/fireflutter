

import { initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions/v2/options";
// import { onValueWritten } from "firebase-functions/v2/database";
// import { setGlobalOptions } from "firebase-functions/v2/options";


// / initialize firebase app
initializeApp();

setGlobalOptions({
    region: "asia-southeast1",
});

export * from "./messaging/messaging.functions";
export * from "./typesense/typesense.functions";
export * from "./forum/forum.functions";


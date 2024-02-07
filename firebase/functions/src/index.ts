

import { initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions/v2/options";
import { Config } from "./config";
// import { onValueWritten } from "firebase-functions/v2/database";
// import { setGlobalOptions } from "firebase-functions/v2/options";


// / initialize firebase app
initializeApp();

setGlobalOptions({
    region: Config.region,
});

export * from "./messaging/messaging.functions";
export * from "./typesense/typesense.functions";
export * from "./forum/forum.functions";




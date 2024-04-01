

import { initializeApp } from "firebase-admin/app";
import { Config } from "./config";
import { setGlobalOptions } from "firebase-functions/v2/options";

// / initialize firebase app
initializeApp(
    // Add database URL for testing
    // { databaseURL: "http://127.0.0.1:6004/?ns=withcenter-test-3" },
);

// For testing, please do not set region on GlobalOptions.
setGlobalOptions({
    region: Config.region,
});

export * from "./messaging/messaging.functions";
export * from "./typesense/typesense.functions";
export * from "./forum/forum.functions";
export * from "./user/user.functions";
export * from "./chat/chat.functions";
export * from "./link/link.functions";



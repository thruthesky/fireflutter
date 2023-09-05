"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const firestore_1 = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
exports.uppercase = (0, firestore_1.onDocumentCreated)("my-collection/{docId}", (event) => {
    var _a, _b;
    /* ... */
    logger.info("Hello logs!", { structuredData: true });
    if (event === undefined || typeof event === "undefined") {
        return;
    }
    return (_a = event.data) === null || _a === void 0 ? void 0 : _a.ref.update({
        doneAt: new Date(),
        uppercase: (_b = event.data) === null || _b === void 0 ? void 0 : _b.data().original.toUpperCase(),
    });
});
//# sourceMappingURL=test.controller.js.map
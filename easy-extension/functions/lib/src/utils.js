"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.failure = exports.success = exports.getChangeType = exports.ChangeType = void 0;
const firestore_1 = require("firebase-admin/firestore");
const config_1 = require("./config");
/**
 * The type of change that was made to the document.
 */
var ChangeType;
(function (ChangeType) {
    ChangeType[ChangeType["CREATE"] = 0] = "CREATE";
    ChangeType[ChangeType["DELETE"] = 1] = "DELETE";
    ChangeType[ChangeType["UPDATE"] = 2] = "UPDATE";
})(ChangeType = exports.ChangeType || (exports.ChangeType = {}));
/**
 * Gets the type of change that was made to the document.
 *
 * @param change the change object from the onWrite function
 * @returns the type of change that was made
 */
const getChangeType = (change) => {
    if (!change.after.exists) {
        return ChangeType.DELETE;
    }
    if (!change.before.exists) {
        return ChangeType.CREATE;
    }
    return ChangeType.UPDATE;
};
exports.getChangeType = getChangeType;
/**
 * Updates the easy command document with the success response.
 *
 * @param ref document of the easy command to update
 * @param response the response to set in the easy comamnd document
 * @returns the result of the update
 */
const success = async (ref, response) => {
    return await ref.update({
        config: config_1.Config.json(),
        response: Object.assign({
            status: "success",
            timestamp: firestore_1.FieldValue.serverTimestamp(),
        }, response),
    });
};
exports.success = success;
/**
 * Updates the easy command document with the failure response.
 *
 * @param ref easy command docuemnt reference to update
 * @param code error code
 * @param message error message
 * @returns the result of the update
 */
const failure = async (ref, code, message) => {
    return await ref.update({
        config: config_1.Config.json(),
        response: {
            status: "error",
            code,
            message,
            timestamp: firestore_1.FieldValue.serverTimestamp(),
        },
    });
};
exports.failure = failure;
//# sourceMappingURL=utils.js.map
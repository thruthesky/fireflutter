"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteUserDocument = exports.createUserDocument = exports.userSync = exports.easyCommand = void 0;
const app_1 = require("firebase-admin/app");
const functions = __importStar(require("firebase-functions"));
const command_model_1 = require("./models/command.model");
const utils_1 = require("./utils");
const config_1 = require("./config");
const user_model_1 = require("./models/user.model");
(0, app_1.initializeApp)();
// easy command
exports.easyCommand = functions.firestore.document("easy-commands/{documentId}")
    .onWrite(async (change) => {
    const changeType = (0, utils_1.getChangeType)(change);
    if (changeType == utils_1.ChangeType.CREATE) {
        return command_model_1.CommandModel.execute(change.after);
    }
    return null;
});
exports.userSync = functions.firestore.document(config_1.Config.userCollectionName + "/{documentId}")
    .onWrite(async (change) => {
    const changeType = (0, utils_1.getChangeType)(change);
    if (changeType == utils_1.ChangeType.CREATE || changeType == utils_1.ChangeType.UPDATE) {
        return user_model_1.UserModel.sync(change.after);
    }
    else if (changeType == utils_1.ChangeType.DELETE) {
        return user_model_1.UserModel.deleteSync(change.before.id);
    }
    return null;
});
/**
 * Creates a user document when a new user account is created.
 */
exports.createUserDocument = functions.auth
    .user()
    .onCreate(async (user) => {
    if (config_1.Config.createUserDocument == false) {
        return;
    }
    /// TODO - 'generatedBy' is now added, check if it's working.
    return user_model_1.UserModel.createDocument(user.uid, Object.assign(Object.assign({}, user_model_1.UserModel.popuplateUserFields(user)), { generatedBy: 'easy-extension' }));
});
exports.deleteUserDocument = functions.auth
    .user()
    .onDelete(async (user) => {
    if (config_1.Config.deleteUserDocument == false) {
        return;
    }
    return user_model_1.UserModel.deleteDocument(user.uid);
});
//# sourceMappingURL=index.js.map
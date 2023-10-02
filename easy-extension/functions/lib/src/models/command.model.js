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
exports.CommandModel = void 0;
const firestore_1 = require("firebase-admin/firestore");
const user_model_1 = require("./user.model");
const functions = __importStar(require("firebase-functions"));
const config_1 = require("../config");
const utils_1 = require("../utils");
/**
 * CommandModel
 *
 * Execute a command from easy-commands collection.
 *
 * TODO : More error tests like options validation, etc.
 */
class CommandModel {
    /**
               * Execute a command from easy-commands collection.
               *
               * @param snapshot DocumentStanpshot that contains a command
               * @returns Promise
               */
    static async execute(snapshot) {
        const command = snapshot.data();
        const ref = snapshot.ref;
        // const uid = ref.id;
        // functions.logger.info('---> input command; ', command);
        try {
            if (command.command === void 0) {
                throw new Error("execution/command-is-undefined");
            }
            else if (command.command === "update_custom_claims") {
                const claims = command.claims;
                await user_model_1.UserModel.updateCustomClaims(command.uid, claims);
                if (config_1.Config.syncCustomClaimsToUserDocument) {
                    await user_model_1.UserModel.update(command.uid, { claims });
                }
                return await (0, utils_1.success)(ref, { claims: await user_model_1.UserModel.getCustomClaims(command.uid) });
            }
            else if (command.command === "get_user") {
                const user = await user_model_1.UserModel.getBy(command.by, command.value);
                return await (0, utils_1.success)(ref, { data: user_model_1.UserModel.popuplateUserFields(user) });
            }
            else if (command.command === "disable_user") {
                await user_model_1.UserModel.disable(command.uid);
                if (config_1.Config.setDisabledUserField) {
                    await user_model_1.UserModel.update(command.uid, { disabled: true });
                }
                return await (0, utils_1.success)(ref, {});
            }
            else if (command.command === "enable_user") {
                await user_model_1.UserModel.enable(command.uid);
                if (config_1.Config.setDisabledUserField) {
                    await user_model_1.UserModel.update(command.uid, { disabled: firestore_1.FieldValue.delete() });
                }
                return await (0, utils_1.success)(ref, {});
            }
            else if (command.command === "delete_user") {
                await user_model_1.UserModel.delete(command.uid);
                return await (0, utils_1.success)(ref, {});
            }
            throw new Error("execution/command-not-found");
        }
        catch (error) {
            // get error
            let code = "execution/error";
            let message = "command execution error.";
            if (error === null || error === void 0 ? void 0 : error.errorInfo) {
                code = error.errorInfo.code;
                message = error.errorInfo.message;
            }
            else {
                code = error.message;
            }
            // log error
            // * This will produce error message on shell if it runs as unit testing.
            functions.logger.error(code, message, command);
            // report
            return await (0, utils_1.failure)(ref, code, message);
        }
    }
}
exports.CommandModel = CommandModel;
//# sourceMappingURL=command.model.js.map
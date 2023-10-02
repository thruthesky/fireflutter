"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Config = void 0;
class Config {
    static json() {
        return {
            userCollectionName: this.userCollectionName,
            setDisabledUserField: this.setDisabledUserField,
            syncCustomClaimsToUserDocument: this.syncCustomClaimsToUserDocument,
            createUserDocument: this.createUserDocument,
            deleteUserDocument: this.deleteUserDocument,
        };
    }
}
exports.Config = Config;
Config.userCollectionName = process.env.USER_COLLECTION_NAME || 'users';
Config.setDisabledUserField = process.env.SYNC_USER_DISABLED_FIELD === 'yes';
Config.syncCustomClaimsToUserDocument = process.env.SYNC_CUSTOM_CLAIMS === 'yes';
Config.createUserDocument = process.env.CREATE_USER_DOCUMENT === 'yes';
Config.deleteUserDocument = process.env.DELETE_USER_DOCUMENT === 'yes';
Config.userSyncFields = process.env.USER_SYNC_FIELDS || 'uid,displayName,firstName,photoUrl,hasPhotoUrl';
;
//# sourceMappingURL=config.js.map
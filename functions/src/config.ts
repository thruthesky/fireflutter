


export class Config {
    static userCollectionName: string =
        process.env.USER_COLLECTION_NAME || 'users';
    static setDisabledUserField: boolean = process.env.SYNC_USER_DISABLED_FIELD === 'yes';
    static syncCustomClaimsToUserDocument: boolean = process.env.SYNC_CUSTOM_CLAIMS === 'yes';
    static createUserDocument: boolean = process.env.CREATE_USER_DOCUMENT === 'yes';
    static deleteUserDocument: boolean = process.env.DELETE_USER_DOCUMENT === 'yes';
    static userSyncFields: string = process.env.USER_SYNC_FIELDS || '';
    static userSyncFieldsBackfill: boolean = process.env.USER_SYNC_FIELDS_BACKFILL === 'yes';
    static userDefaultFields: string = process.env.USER_DEFAULT_FIELDS || ""; // ? JSON.parse(process.env.USER_DEFAULT_FIELDS) : {};


    static json(): Record<string, any> {
        return {
            userCollectionName: this.userCollectionName,
            setDisabledUserField: this.setDisabledUserField,
            syncCustomClaimsToUserDocument: this.syncCustomClaimsToUserDocument,
            createUserDocument: this.createUserDocument,
            deleteUserDocument: this.deleteUserDocument,
            userSyncFields: this.userSyncFields,
            userSyncFieldsBackfill: this.userSyncFieldsBackfill,
            userDefaultFields: this.userDefaultFields,
        };
    }
};

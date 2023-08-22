

import { initializeApp } from "firebase-admin/app";
import {
  DocumentSnapshot,
  WriteResult,
} from "firebase-admin/firestore";


import * as functions from "firebase-functions";
import { CommandModel } from "./models/command.model";
import { ChangeType, getChangeType } from "./utils";
import { Config } from "./config";
import { UserModel } from "./models/user.model";
import { UserRecord } from "firebase-admin/auth";


initializeApp();

// easy command
export const easyCommand = functions.firestore.document("easy-commands/{documentId}")
  .onWrite(async (change: functions.Change<DocumentSnapshot>): Promise<WriteResult | undefined | null> => {
    const changeType = getChangeType(change);
    if (changeType == ChangeType.CREATE) {
      return CommandModel.execute(change.after);
    }
    return null;
  });

export const userSync = functions.firestore.document(Config.userCollectionName + "/{documentId}")
  .onWrite(async (change: functions.Change<DocumentSnapshot>): Promise<WriteResult | void | null> => {
    const changeType = getChangeType(change);


    if (changeType == ChangeType.CREATE || changeType == ChangeType.UPDATE) {
      return UserModel.sync(change.after);
    } else if (changeType == ChangeType.DELETE) {
      return UserModel.deleteSync(change.before.id);
    }
    return null;
  });



/**
 * Creates a user document when a new user account is created.
 */
export const createUserDocument = functions.auth
  .user()
  .onCreate(async (user: UserRecord): Promise<WriteResult | void> => {
    if (Config.createUserDocument == false) {
      return;
    }
    /// TODO - 'generatedBy' is now added, check if it's working.
    return UserModel.createDocument(user.uid, { ...UserModel.popuplateUserFields(user), ...{ generatedBy: 'easy-extension' } });
  });

export const deleteUserDocument = functions.auth
  .user()
  .onDelete(async (user: UserRecord): Promise<WriteResult | void> => {
    if (Config.deleteUserDocument == false) {
      return;
    }
    return UserModel.deleteDocument(user.uid);
  });


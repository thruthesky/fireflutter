

import { initializeApp } from "firebase-admin/app";
import { getExtensions } from "firebase-admin/extensions";
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

// user sync
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

// user sync backfill
export const userSyncBackFillingTask = functions.tasks.taskQueue()
  .onDispatch(async () => {

    const runtime = getExtensions().runtime();
    if (Config.userSyncFieldsBackfill == false) {
      await runtime.setProcessingState(
        "PROCESSING_COMPLETE",
        "Existing documents were not backfilled because 'Backfill options' was configured to no." +
        " If you want to backfill existing documents, reconfigure this instance."
      );
      return;
    }

    await UserModel.syncBackfill();

    // When processing is complete, report status to the user (see below).
    //
    await runtime.setProcessingState(
      "PROCESSING_COMPLETE",
      `Successfully re-synced all the documents.`
    );

    functions.logger.info("Done backfilling to user searchable fields from /users firestore collection");
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
    let data = {};
    if (Config.userDefaultFields) {
      data = JSON.parse(Config.userDefaultFields);
    }
    return UserModel.createDocument(user.uid, { ...UserModel.popuplateUserFields(user), ...data });
  });

// User delete
export const deleteUserDocument = functions.auth
  .user()
  .onDelete(async (user: UserRecord): Promise<WriteResult | void> => {
    if (Config.deleteUserDocument == false) {
      return;
    }
    return UserModel.deleteDocument(user.uid);
  });



import * as logger from "firebase-functions/logger";

import { initializeApp } from "firebase-admin/app";
import {
  DocumentSnapshot,
  // DocumentSnapshot,
  // QueryDocumentSnapshot,
  WriteResult,
  // getFirestore,
} from "firebase-admin/firestore";
// import {
//   // FirestoreEvent,
//   onDocumentCreated,
// } from "firebase-functions/v2/firestore";

import * as functions from "firebase-functions";
import { CommandModel } from "./models/command.model";
import { ChangeType, getChangeType } from "./utils";
import { Config } from "./config";
import { UserModel } from "./models/user.model";
import { UserRecord } from "firebase-admin/auth";
// import { FirestoreEventType } from "./defines";


initializeApp();
// const db = getFirestore();


//
export const easyCommand = functions.firestore.document("easy-commands/{documentId}")
  .onWrite(async (change: functions.Change<DocumentSnapshot>): Promise<WriteResult | undefined | null> => {
    const changeType = getChangeType(change);

    logger.info('--> onDocumentCreated(easy-commands/{documentId}) onWrite() start with changeType;', changeType);

    switch (changeType) {
      case ChangeType.CREATE: {
        logger.info("--> onDocumentCreated(easy-commands/{documentId}) onWrite() create -> change.after.id;", change.after.id, change.after.data());
        return CommandModel.execute(change.after);
      }
      case ChangeType.DELETE:
        break;
      case ChangeType.UPDATE:
        break;
      default: {
        throw new Error(`Invalid change type: ${changeType}`);
      }
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
    return UserModel.createDocument(user.uid, UserModel.popuplateUserFields(user));
  });

export const deleteUserDocument = functions.auth
  .user()
  .onDelete(async (user: UserRecord): Promise<WriteResult | void> => {
    if (Config.deleteUserDocument == false) {
      return;
    }
    return UserModel.deleteDocument(user.uid);
  });


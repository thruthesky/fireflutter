import { DocumentReference, DocumentSnapshot, FieldValue, WriteResult } from "firebase-admin/firestore";
import * as functions from "firebase-functions";
import { Config } from "./config";

export enum ChangeType {
  CREATE,
  DELETE,
  UPDATE,
}


export const getChangeType = (change: functions.Change<DocumentSnapshot>): ChangeType => {
  if (!change.after.exists) {
    return ChangeType.DELETE;
  }
  if (!change.before.exists) {
    return ChangeType.CREATE;
  }
  return ChangeType.UPDATE;
};


export const success = async (ref: DocumentReference, response: Record<string, any>): Promise<WriteResult> => {
  return await ref.update({
    config: Config.json(),
    response:
    {
      ...{
        status: "success",
        timestamp: FieldValue.serverTimestamp(),
      },
      ...response,
    },
  });
}

export const failure = async (ref: DocumentReference, code: string, message: string): Promise<WriteResult> => {
  return await ref.update({
    config: Config.json(),
    response:
    {
      status: "error",
      code,
      message,
      timestamp: FieldValue.serverTimestamp(),
    },
  });
}

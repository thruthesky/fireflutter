import { DocumentReference, DocumentSnapshot, FieldValue, WriteResult } from "firebase-admin/firestore";
import * as functions from "firebase-functions";
import { Config } from "./config";

/**
 * The type of change that was made to the document.
 */
export enum ChangeType {
  CREATE,
  DELETE,
  UPDATE,
}


/**
 * Gets the type of change that was made to the document.
 * 
 * @param change the change object from the onWrite function
 * @returns the type of change that was made
 */
export const getChangeType = (change: functions.Change<DocumentSnapshot>): ChangeType => {
  if (!change.after.exists) {
    return ChangeType.DELETE;
  }
  if (!change.before.exists) {
    return ChangeType.CREATE;
  }
  return ChangeType.UPDATE;
};


/**
 * Updates the easy command document with the success response.
 * 
 * @param ref document of the easy command to update
 * @param response the response to set in the easy comamnd document
 * @returns the result of the update
 */
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

/**
 * Updates the easy command document with the failure response.
 * 
 * @param ref easy command docuemnt reference to update
 * @param code error code
 * @param message error message
 * @returns the result of the update
 */
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

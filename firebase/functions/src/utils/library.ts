import * as functions from "firebase-functions";

export enum CallableError {
  ok = "ok",
  cancelled = "cancelled",
  unknown = "unknown",
  invalidArgument = "invalid-argument",
  notFound = "not-found",
  alreadyExists = "already-exists",
  permissionDenied = "permission-denied",
  failedPrecondition = "failed-precondition",
  aborted = "aborted",
  unimplemented = "unimplemented",
  unavailable = "unavailable",
  unauthenticated = "unauthenticated",
}

export function invalidArgument(message: string, details?: unknown) {
  return new functions.https.HttpsError(CallableError.invalidArgument, message, details);
}

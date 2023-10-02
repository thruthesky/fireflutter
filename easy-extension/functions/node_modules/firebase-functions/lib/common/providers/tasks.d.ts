import { DecodedIdToken } from "firebase-admin/auth";
import { Expression } from "../../params";
import { ResetValue } from "../options";
/** How a task should be retried in the event of a non-2xx return. */
export interface RetryConfig {
    /**
     * Maximum number of times a request should be attempted.
     * If left unspecified, will default to 3.
     */
    maxAttempts?: number | Expression<number> | ResetValue;
    /**
     * Maximum amount of time for retrying failed task.
     * If left unspecified will retry indefinitely.
     */
    maxRetrySeconds?: number | Expression<number> | ResetValue;
    /**
     * The maximum amount of time to wait between attempts.
     * If left unspecified will default to 1hr.
     */
    maxBackoffSeconds?: number | Expression<number> | ResetValue;
    /**
     * The maximum number of times to double the backoff between
     * retries. If left unspecified will default to 16.
     */
    maxDoublings?: number | Expression<number> | ResetValue;
    /**
     * The minimum time to wait between attempts. If left unspecified
     * will default to 100ms.
     */
    minBackoffSeconds?: number | Expression<number> | ResetValue;
}
/** How congestion control should be applied to the function. */
export interface RateLimits {
    /**
     * The maximum number of requests that can be processed at a time.
     * If left unspecified, will default to 1000.
     */
    maxConcurrentDispatches?: number | Expression<number> | ResetValue;
    /**
     * The maximum number of requests that can be invoked per second.
     * If left unspecified, will default to 500.
     */
    maxDispatchesPerSecond?: number | Expression<number> | ResetValue;
}
/** Metadata about the authorization used to invoke a function. */
export interface AuthData {
    uid: string;
    token: DecodedIdToken;
}
/** Metadata about a call to a Task Queue function. */
export interface TaskContext {
    /**
     * The result of decoding and verifying an ODIC token.
     */
    auth?: AuthData;
}
/**
 * The request used to call a Task Queue function.
 */
export interface Request<T = any> {
    /**
     * The parameters used by a client when calling this function.
     */
    data: T;
    /**
     * The result of decoding and verifying an ODIC token.
     */
    auth?: AuthData;
}

import { CloudFunction as CloudFunctionV1, HttpsFunction, Runnable } from 'firebase-functions';
import { CloudFunction as CloudFunctionV2, CloudEvent } from 'firebase-functions/v2';
import { WrappedFunction, WrappedScheduledFunction } from './v1';
import { WrappedV2Function } from './v2';
export { ContextOptions, EventContextOptions, WrappedFunction, WrappedScheduledFunction, CallableContextOptions, makeChange, mockConfig, } from './v1';
export { WrappedV2Function } from './v2';
export declare function wrap<T>(cloudFunction: HttpsFunction & Runnable<T>): WrappedFunction<T, HttpsFunction & Runnable<T>>;
export declare function wrap<T>(cloudFunction: CloudFunctionV1<T>): WrappedScheduledFunction | WrappedFunction<T>;
export declare function wrap<T extends CloudEvent<unknown>>(cloudFunction: CloudFunctionV2<T>): WrappedV2Function<T>;

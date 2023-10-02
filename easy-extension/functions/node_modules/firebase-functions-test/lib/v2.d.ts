import { CloudFunction, CloudEvent } from 'firebase-functions/v2';
import { DeepPartial } from './cloudevent/types';
/** A function that can be called with test data and optional override values for {@link CloudEvent}
 * It will subsequently invoke the cloud function it wraps with the provided {@link CloudEvent}
 */
export type WrappedV2Function<T extends CloudEvent<unknown>> = (cloudEventPartial?: DeepPartial<T | object>) => any | Promise<any>;
/**
 * Takes a v2 cloud function to be tested, and returns a {@link WrappedV2Function}
 * which can be called in test code.
 */
export declare function wrapV2<T extends CloudEvent<unknown>>(cloudFunction: CloudFunction<T>): WrappedV2Function<T>;

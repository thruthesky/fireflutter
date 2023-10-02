/**
 * @hidden
 * @alpha
 */
import { BooleanParam, Expression, IntParam, Param, ParamOptions, SecretParam, StringParam, ListParam } from "./types";
export { ParamOptions, Expression };
type SecretOrExpr = Param<any> | SecretParam;
export declare const declaredParams: SecretOrExpr[];
/**
 * A builtin param that resolves to the default RTDB database URL associated
 * with the project, without prompting the deployer. Empty string if none exists.
 */
export declare const databaseURL: Param<string>;
/**
 * A builtin param that resolves to the Cloud project ID associated with
 * the project, without prompting the deployer.
 */
export declare const projectID: Param<string>;
/**
 * A builtin param that resolves to the Cloud project ID, without prompting
 * the deployer.
 */
export declare const gcloudProject: Param<string>;
/**
 * A builtin param that resolves to the Cloud storage bucket associated
 * with the function, without prompting the deployer. Empty string if not
 * defined.
 */
export declare const storageBucket: Param<string>;
/**
 * Declares a secret param, that will persist values only in Cloud Secret Manager.
 * Secrets are stored interally as bytestrings. Use ParamOptions.`as` to provide type
 * hinting during parameter resolution.
 *
 * @param name The name of the environment variable to use to load the param.
 * @param options Configuration options for the param.
 * @returns A Param with a `string` return type for `.value`.
 */
export declare function defineSecret(name: string): SecretParam;
/**
 * Declare a string param.
 *
 * @param name The name of the environment variable to use to load the param.
 * @param options Configuration options for the param.
 * @returns A Param with a `string` return type for `.value`.
 */
export declare function defineString(name: string, options?: ParamOptions<string>): StringParam;
/**
 * Declare a boolean param.
 *
 * @param name The name of the environment variable to use to load the param.
 * @param options Configuration options for the param.
 * @returns A Param with a `boolean` return type for `.value`.
 */
export declare function defineBoolean(name: string, options?: ParamOptions<boolean>): BooleanParam;
/**
 * Declare an integer param.
 *
 * @param name The name of the environment variable to use to load the param.
 * @param options Configuration options for the param.
 * @returns A Param with a `number` return type for `.value`.
 */
export declare function defineInt(name: string, options?: ParamOptions<number>): IntParam;
/**
 * Declare a list param.
 *
 * @param name The name of the environment variable to use to load the param.
 * @param options Configuration options for the param.
 * @returns A Param with a `string[]` return type for `.value`.
 */
export declare function defineList(name: string, options?: ParamOptions<string[]>): ListParam;

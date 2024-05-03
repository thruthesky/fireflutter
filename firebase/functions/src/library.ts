import { DataSnapshot } from "firebase-admin/database";
import { Change } from "firebase-functions/lib/common/change";
import { DatabaseEvent } from "firebase-functions/v2/database";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const chunk = (arr: any[], size: number) =>
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    Array.from({ length: Math.ceil(arr.length / size) }, (_: any, i: number) =>
        arr.slice(i * size, i * size + size)
    );


/**
 * Returns true if the event is a create event
 *
 * @param event DatabaseEvent<Change<DataSnapshot>>
 * @returns boolean
 */
export function isCreate(event: DatabaseEvent<Change<DataSnapshot>>): boolean {
    return !event.data.before.exists() && event.data.after.exists();
}


/**
 * Returns true if the event is an update event
 *
 * @param event DatabaseEvent<Change<DataSnapshot>>
 * @returns boolean
 */
export function isUpdate(event: DatabaseEvent<Change<DataSnapshot>>): boolean {
    return event.data.before.exists() && event.data.after.exists();
}

/**
 * Return true if the event is a delete event
 *
 * @param event DatabaseEvent<Change<DataSnapshot>>
 * @returns boolean
 */
export function isDelete(event: DatabaseEvent<Change<DataSnapshot>>): boolean {
    return event.data.before.exists() && !event.data.after.exists();
}


/**
 * Returns a string that is cut to the length.
 * @param str string to cut.
 * @param length length of the string after cutting
 * @returns string
 */
export function strcut(str: string, length: number): string {
    return str.length > length ? str.substring(0, length) : str;
}

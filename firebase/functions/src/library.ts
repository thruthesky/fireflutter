import { DataSnapshot } from "firebase-admin/database";
import { Change } from "firebase-functions/lib/common/change";
import { DatabaseEvent } from "firebase-functions/v2/database";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const chunk = (arr: any[], size: number) =>
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    Array.from({ length: Math.ceil(arr.length / size) }, (_: any, i: number) =>
        arr.slice(i * size, i * size + size)
    );



export function isCreate(event: DatabaseEvent<Change<DataSnapshot>>): boolean {
    return !event.data.before.exists() && event.data.after.exists();
}


export function isUpdate(event: DatabaseEvent<Change<DataSnapshot>>): boolean {
    return event.data.before.exists() && event.data.after.exists();
}

export function isDelete(event: DatabaseEvent<Change<DataSnapshot>>): boolean {
    return event.data.before.exists() && !event.data.after.exists();
}

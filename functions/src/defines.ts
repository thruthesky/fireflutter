import {QueryDocumentSnapshot} from "firebase-admin/firestore";
import {FirestoreEvent} from "firebase-functions/v2/firestore";

export type FirestoreEventType = FirestoreEvent<QueryDocumentSnapshot | undefined, {
    documentId: string;
}>;

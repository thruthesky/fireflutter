/**
 * Typesense interface for User
 */
export interface TypesenseUser {
    type?: "user" | "post" | "comment";
    uid?: string;
    displayName?: string;
    createdAt?: number;
}

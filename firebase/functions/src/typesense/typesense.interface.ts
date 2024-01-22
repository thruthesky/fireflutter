/**
 * Typesense interface for User, Post, Comment doc
 */
export interface TypesenseDoc {
    id?: string;
    type?: "user" | "post" | "comment";

    // User
    uid?: string;
    displayName?: string;
    photoUrl?: string;
    isVerified?: boolean;

    // Post
    title?: string;
    content?: string;
    category?: string;
    noOfLikes?: number;
    urls?: Array<string>;
    noOfCommments?: number;
    deleted?: boolean;

    // Comment
    parentId?: string;
    postId?: string;

    createdAt?: number;
}

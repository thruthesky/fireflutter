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
    title?: string | null;
    content?: string;
    category?: string;
    // noOfLikes?: number;
    urls?: Array<string>;
    url?: string | null; // used only for typesense
    // noOfCommments?: number;
    deleted?: boolean;

    // Comment
    parentId?: string;
    postId?: string;

    createdAt?: number;
}

export interface TypesensePostCreate {
    category: string;
    content?: string;
    createdAt: number;
    deleted?: boolean;
    id: string;
    title?: string;
    type: "post";
    uid: string;
    url?: string | null;
}

export interface TypesensePostUpdate {
    id: string;
    content?: string;
    title?: string;
    url?: string | null;
    createdAt: number;
}

export interface PostCreateEvent {
    title?: string;
    content?: string;
    uid: string;
    urls?: Array<string>;
    createdAt: number;
}

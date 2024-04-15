
/**
 * Post Model for Firestore's Posts
 */
export interface FirestorePost {
    uid?: string | null;
    title?: string | null;
    content?: string | null;
    urls?: Array<string> | null;
    category?: string | null;
    createdAt?: number | null;
    order?: number | null;
    deleted?: boolean | null;
}

/**
 * Post Model for Firestore's Posts
 */
export interface FirestorePostWithExtra {
    uid?: string | null;
    title?: string | null;
    content?: string | null;
    urls?: Array<string> | null;
    category?: string | null;
    createdAt?: number | null;
    order?: number | null;
    deleted?: boolean | null;

    // from here, the extra fields
    mapField?: {
        test?: number | null;
    };
}

/**
 * Comment Model for Firestore's Posts
 */
export interface FirestoreComment {
    uid?: string | null;
    postId?: string | null;
    category?: string | null;
    content?: string | null;
    createdAt?: number | null;
    deleted?: boolean | null;
    urls?: Array<string> | null;
}

/**
 * Comment Create for RTDB
 */
export interface CommentCreateEvent {
    uid?: string | null;
    parentId?: string | null;
    category?: string | null;
    content?: string | null;
    createdAt?: number | null;
    deleted?: boolean | null;
    urls?: Array<string> | null;
}

/**
 * Comment Create for RTDB
 */
export interface CommentUpdateEvent {
    content?: string | null;
    createdAt?: number | null;
    deleted?: boolean | null;
    urls?: Array<string> | null;
}

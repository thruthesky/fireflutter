export interface PostCreateEvent {
    uid: string;
    title?: string;
    content?: string;
    urls?: Array<string>;
    createdAt: number;
    order: number;
    deleted?: boolean;
}

export interface PostSummary {
    uid: string;
    title?: string;
    content?: string;
    url?: string;
    createdAt: number;
    order: number;
    deleted?: boolean;
}

export interface Post {
    uid?: string | null;
    title?: string | null;
    content?: string | null;
    urls?: Array<string> | null;
    createdAt?: number | null;
    order?: number | null;
    deleted?: boolean | null;
}

export interface PostUpdateEvent {
    title?: string;
    content?: string;
    urls?: Array<string>;
    deleted?: boolean;
}


export interface PostSummaryUpdateEvent {
    uid?: string | null;
    createdAt?: number | null;
    order?: number | null;
    title?: string | null;
    content?: string | null;
    url?: string | null;
    deleted?: boolean | null;
}

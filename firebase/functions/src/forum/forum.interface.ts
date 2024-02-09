export interface PostCreateEvent {
    uid: string;
    title?: string;
    content?: string;
    urls?: Array<string>;
    createdAt: number;
    order: number;
}

export interface PostSummary {
    uid: string;
    title: string;
    content: string;
    url: string;
    createdAt: number;
    order: number;
}


export interface PostUpdateEvent {
    title?: string;
    content?: string;
    urls?: Array<string>;
    deleted?: boolean;
}

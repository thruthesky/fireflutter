
export interface PostCreateEvent {
    uid: string;
    title?: string;
    content?: string;
    urls?: Array<string>;
    createdAt: number;
}

export interface PostUpdateEvent {
    title?: string;
    content?: string;
    urls?: Array<string>;
    deleted?: boolean;
}



/**
 * RTDB 에 글 쓰기 이벤트가 발생하면, (posts/categoriy/id 에 글이 작성되면) onValueCreate 클라우드 함수에서
 * 전달되는 값을 표현한 interface 이다.
 */
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

export interface PostSummaryAll {
    uid: string;
    title?: string;
    content?: string;
    url?: string;
    createdAt: number;
    order: number;
    deleted?: boolean;
    category: string;
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
    title?: string | null;
    content?: string | null;
    urls?: Array<string> | null;
    deleted?: boolean | null;
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


export interface Comment {
    id?: string;
    postId: string;
    parentId?: string;
    category: string;
    content?: string;
    uid: string;
    urls?: string[];
    createdAt?: number | object;
    likes?: Array<string>;
    deleted?: boolean;
    order?: number;

}

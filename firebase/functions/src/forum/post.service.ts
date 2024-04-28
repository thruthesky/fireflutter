import { getDatabase } from "firebase-admin/database";
import { Post, PostCreateEvent, PostSummary, PostSummaryAll } from "./forum.interface";
import { Config } from "../config";

/**
 * PostService
 *
 */
export class PostService {

    /**
     * 글을 가져와 리턴한다.
     * 만약, 글의 특정 필드만 가져오고 싶다면, getField 를 사용한다.
     * 
     * @param category 카테고리
     * @param postId 글 아이디
     * @returns 글 내용
     */
    static async get(category: string, postId: string): Promise<Post> {
        const db = getDatabase();
        const data = (await db.ref(`${Config.posts}/${category}/${postId}`).get()).val();
        return data as Post;

    }

    /**
     * 글 필드 내용을 가져와 리턴한다.
     * 
     * @param category 카테고리
     * @param postId 글 아이디
     * @param field 필드
     * @returns 필드의 내용을 리턴한다.
     */
    static async getField(category: string, postId: string, field: string): Promise<Post | any> {
        const db = getDatabase();
        const data = (await db.ref(`${Config.posts}/${category}/${postId}/${field}`).get()).val();
        return data as any;

    }


    /**
     * Sets the summary of the post in `post-summaries` and `post-all-summary`
     *
     * @param post post data from the event
     * @param category category of the post
     * @param id id of the post
     * @returns the promise of the operation
     */
    static async setSummary(post: PostCreateEvent, category: string, id: string,) {
        const summary = {
            uid: post.uid,
            createdAt: post.createdAt,
            order: -post.createdAt,
            title: post.title ?? null,
            content: post.content ?? null,
            url: post.urls?.[0] ?? null,
            deleted: post.deleted ?? null,
        } as PostSummary;

        const db = getDatabase();
        await db.ref(`${Config.postSummaries}/${category}/${id}`).update(summary);
        const summaryAll: PostSummaryAll = {
            ...summary,
            category,
        };
        await db.ref(`${Config.postAllSummaries}/${id}`).update(summaryAll);
        return;
    }


    /**
     * deletes the summary of the post in `post-summaries` and `post-all-summary`
     *
     * @param category category of the post
     * @param postId post id
     */
    static async deleteSummary(category: string, postId: string) {
        const db = getDatabase();
        await db.ref(`${Config.postSummaries}/${category}/${postId}`).remove();
        await db.ref(`${Config.postAllSummaries}/${postId}`).remove();
    }
}

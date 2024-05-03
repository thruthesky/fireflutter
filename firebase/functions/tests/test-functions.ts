import { getDatabase } from "firebase-admin/database";
import { randomString } from "./firebase-test-functions";
import { Config } from "../src/config";

/**
 * Create a test user and return its uid.
 *
 * @param options
 *  - options.tokens: The tokens of the user.
 *  - options.commentNotification: The comment notification settings of the user.
 *
 * @example
 * const a = await createTestUser();
 */
export async function createTestUser(options?: {
    tokens?: string[],
    commentNotification?: boolean
}): Promise<string> {
    const uid = randomString();
    await getDatabase().ref("users/" + uid).set({
        displayName: uid,
    });
    if (options?.tokens) {
        for (const token of options.tokens) {
            await getDatabase().ref(Config.userFcmTokens + "/" + token).set({
                uid,
                platform: "test",
            });
        }
    }
    if (options?.commentNotification) {
        await getDatabase().ref(Config.userSettings + "/" + uid).set({
            commentNotification: true,
        });
    }
    return uid;
}


/**
 * Create a test post under the test category with the input uid and return its post id.
 *
 * @example
 * const p1 = await createTestPost({ uid: a });
 */
export async function createTestPost(input: { uid: string, category?: string, title?: string }): Promise<string> {
    const uid = input.uid;
    const category = input.category || "test";
    const title = input.title || "title";

    const ref = getDatabase().ref("posts").child(category).push();
    await ref.set({
        uid,
        title,
    });
    return ref.key!;
}


/**
 * Create a test comment under the test post with the input uid and return its comment id.
 *
 * @example
 * const c1 = await createTestComment({ uid: a, postId: p1 });
 */
export async function createTestComment(input: {
    uid: string,
    postId: string,
    parentId?: string,
    category?: string,
    content?: string
}): Promise<string> {
    const uid = input.uid;
    const postId = input.postId;
    const parentId = input.parentId;
    const category = input.category || "test";
    const content = input.content || "content";

    const data: any = {
        uid,
        category,
    };
    if (parentId) {
        data["parentId"] = parentId;
    }
    if (content) {
        data["content"] = content;
    }


    const ref = getDatabase().ref("comments").child(postId).push();
    await ref.set(data);
    return ref.key!;
}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Comment = void 0;
const admin = require("firebase-admin");
const ref_1 = require("../utils/ref");
const library_1 = require("../utils/library");
const post_model_1 = require("./post.model");
class Comment {
    static async get(id) {
        const snapshot = await ref_1.Ref.commentDoc(id).get();
        if (snapshot.exists === false)
            return null;
        const data = snapshot.data();
        data.id = id;
        return data;
    }
    // get comment ancestor by getting parent
    // comment until it reach the root comment
    // return the uids of the author
    /**
     * Return an array of user uid of the ancestors of the comment id.
     * @param commentId comment id to get the ancestor's uid
     * @param authorUid the user uid of the comment id. If it is set,
     *  then the anotherUid will not be included in the result uid array.
     *  It should be the author uid of the commentId. But It can be any uid.
     * @return Returns the uid of ancestors.
     */
    static async getAncestorsUid(commentId, authorUid) {
        let comment = await Comment.get(commentId);
        const uids = [comment === null || comment === void 0 ? void 0 : comment.uid];
        while (comment != null &&
            comment.parentId &&
            comment.parentId !=
                comment.postId) {
            comment = await Comment.get(comment.parentId);
            if (comment == null)
                break;
            uids.push(comment.uid);
        }
        // return uids.filter((v, i, a) => a.indexOf(v) === i); // remove duplicate
        // remove duplicates and remove authorUid
        return [...new Set(uids)].filter((v) => v != authorUid);
    }
    /**
     * 코멘트가 작성되면, 코멘트의 dpeth 와 order 를 업데이트하여, 트리 구조 목록과 들여쓰기를 할 수 있도록 한다.
     *
     * 참고, 글에 noOfComments 는 다른 곳에서 업데이트하고 있다.
     *
     * @param comment 코멘트 문서
     * @param commentId 코멘트 문서 id
     * @returns
     */
    static async updateMeta(comment, commentId) {
        const post = await post_model_1.Post.get(comment.postId);
        let parent;
        if (comment.parentId) {
            parent = await Comment.get(comment.parentId);
        }
        const order = library_1.Library.commentOrder(parent === null || parent === void 0 ? void 0 : parent.sort, parent === null || parent === void 0 ? void 0 : parent.depth, post.noOfComments);
        return ref_1.Ref.commentDoc(commentId).update({
            category: post.categoryId,
            depth: (parent === null || parent === void 0 ? void 0 : parent.depth) ? parent.depth + 1 : 1,
            order: order,
        });
    }
    /**
     * 만약, 코멘트가 삭제되었으면, 즉, `{deleted: true}` 이면, 내용과 업로드된 파일을 삭제한다.
     * @param after 글 after snapshot
     */
    static async checkDelete(after) {
        const data = after.data();
        if (data.deleted) {
            console.log("--> comment deleted. going to empty the document");
            if (data.files && data.files.length > 0) {
                // delete files in firebase storage from data.files array
                for (const url of data.files) {
                    const path = library_1.Library.getPathFromUrl(url);
                    const fileRef = admin.storage().bucket().file(path);
                    await fileRef.delete();
                }
            }
            return after.ref.update({
                content: "",
                files: [],
            });
        }
        else {
            return null;
        }
    }
}
exports.Comment = Comment;
//# sourceMappingURL=comment.model.js.map
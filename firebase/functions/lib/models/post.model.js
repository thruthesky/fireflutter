"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Post = void 0;
const admin = require("firebase-admin");
const library_1 = require("../utils/library");
const ref_1 = require("../utils/ref");
class Post {
    /**
     * Returns the post document in `PostDocument` format.
     *
     * If the post does not exist, it will return an empty object.
     *
     * @param id post id
     * @return data object of the post document
     */
    static async get(id) {
        const snapshot = await ref_1.Ref.postDoc(id).get();
        if (snapshot.exists == false)
            return {};
        const data = snapshot.data();
        data.id = id;
        return data;
    }
    static increaseNoOfComments(postDocumentReference) {
        return postDocumentReference.update({
            noOfComments: admin.firestore.FieldValue.increment(1),
            hasComments: true,
        });
    }
    /**
     * 글 작성 후 이 함수를 호출하면 된다. 그러면 필요한 추가적인 정보를 업데이트한다.
     * @param snapshot 글 snapshot
     * @param uid 회원 uid
     * @return WriteResult
     */
    static updateMeta(snapshot) {
        const createdAt = admin.firestore.FieldValue.serverTimestamp();
        return snapshot.ref.update({
            createdAt,
        });
    }
    /**
     * 만약, 글이 삭제되었으면, noOfComment 가 0 이면, 문서 삭제. 아니면 내용 삭제.
     * @param after 글 after snapshot
     */
    static async checkDelete(after) {
        const data = after.data();
        if (data.deleted) {
            console.log("--> post deleted. going to delete the document");
            if (!data.noOfComments || data.noOfComments == 0) {
                return after.ref.delete();
            }
            else {
                if (data.urls && data.urls.length > 0) {
                    // delete files in firebase storage from data.files array
                    for (const url of data.urls) {
                        const path = library_1.Library.getPathFromUrl(url);
                        const fileRef = admin.storage().bucket().file(path);
                        await fileRef.delete();
                    }
                }
                return after.ref.update({
                    title: "",
                    content: "",
                    files: [],
                });
            }
        }
        else {
            console.log("--> post not deleted.");
            return null;
        }
    }
}
exports.Post = Post;
//# sourceMappingURL=post.model.js.map
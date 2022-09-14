import { CommentDocument } from "../interfaces/comment.interface";
import { Ref } from "../utils/ref";

export class Comment {
  static async get(id: string): Promise<CommentDocument> {
    const data = (await Ref.commentDoc(id).get()).data() as CommentDocument;
    data.id = id;
    return data;
  }
}

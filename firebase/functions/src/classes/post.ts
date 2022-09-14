import { PostDocument } from "../interfaces/post.interface";
import { Ref } from "../utils/ref";

export class Post {
  static async get(id: string): Promise<PostDocument> {
    const data = (await Ref.postDoc(id).get()).data() as PostDocument;
    data.id = id;
    return data;
  }
}

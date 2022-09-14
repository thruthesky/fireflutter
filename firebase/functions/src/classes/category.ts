import * as admin from "firebase-admin";
import { Ref } from "../utils/ref";
import { CategoryDocument } from "../interfaces/category.interface";

export class Category {
  /**
   * Returns category
   * @param id category id
   * @returns category data or null
   */
  static async get(id: string): Promise<CategoryDocument | null> {
    const snapshot = await Ref.categoryDoc(id).get();
    if (snapshot.exists) {
      const data = snapshot.data() as CategoryDocument;
      data.id = id;
      return data;
    } else {
      return null;
    }
  }

  static async set(id: string, data: { [key: string]: any }): Promise<admin.firestore.WriteResult> {
    return Ref.categoryDoc(id).set(data, { merge: true });
  }
}

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { Ref } from "../utils/ref";
import { CategoryDocument } from "../interfaces/category.interface";

export class Category {
  /**
   * Returns category
   * @param categoryId category categoryId
   * @returns category data or null
   */
  static async get(categoryId: string): Promise<CategoryDocument | null> {
    if (!categoryId) {
      functions.logger.log("Category.get() categoryId is empty:");
      throw Error("categoryId is empty on Category.get(categoryId)");
    }
    const snapshot = await Ref.categoryDoc(categoryId).get();
    if (snapshot.exists) {
      const data = snapshot.data() as CategoryDocument;
      data.id = categoryId;
      return data;
    } else {
      return null;
    }
  }

  static async set(
      categoryId: string,
      data: { [key: string]: any }
  ): Promise<admin.firestore.WriteResult> {
    return Ref.categoryDoc(categoryId).set(data, { merge: true });
  }
}

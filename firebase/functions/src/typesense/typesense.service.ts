import { typesenseApiKey, typesenseHost, typesensePort, typesenseProtocol } from "../key";
import { TypesenseDoc } from "./typesense.interface";
import * as Typesense from "typesense";

/**
 * Typesense Service
 *
 * This service is responsible for all the Typesense related operations.
 */
export class TypesenseService {
  /**
   * Test Search
   * TODO need customizable collection
   */
  static collection = "momcafeSearch";

  /**
   *
   */
  static get client() {
    return new Typesense.Client({
      nodes: [
        {
          host: typesenseHost,
          port: typesensePort,
          protocol: typesenseProtocol,
        },
      ],
      apiKey: typesenseApiKey,
      numRetries: 3, // A total of 4 tries (1 original try + 3 retries)
      connectionTimeoutSeconds: 120, // Set a longer timeout for large imports
      // logLevel: "debug",
    });
  }

  /**
   * Upserts the Document in the Typesense.
   * @param doc Either user, post, comment
   * @returns
   */
  static async upsert(doc: TypesenseDoc) {
    const result = await this.client
      .collections(this.collection)
      .documents().upsert(doc);
    return result;
  }

  /**
   * Search User
   * @param searchText
   */
  static async searchUser({ searchText = "", filterBy = "" }) {
    const result = await this.client.collections(this.collection
      ).documents().search({
        q: searchText,
        query_by: "displayName",
        filter_by: filterBy,
      });
     return result;
  }

  /**
   * Search Post
   */
  static async searchPost({ searchText = "", filterBy = "" }) {
    const result = await this.client.collections(this.collection
      ).documents().search({
        q: searchText,
        query_by: "content,title",
        filter_by: filterBy,
      });
     return result;
  }

  /**
  * Search Comment
  */
 static async searchComment({ searchText = "", filterBy = "" }) {
   const result = await this.client.collections(this.collection
     ).documents().search({
       q: searchText,
       query_by: "content",
       filter_by: filterBy,
     });
    return result;
 }

  /**
   * Retrieve User
   * @param id
   * @returns
   */
  static async retrieve( id: string ) {
    const result = await this.client.collections(this.collection
      ).documents(id).retrieve();
     return result;
  }

  /**
   * delete typesense document
   *
   * @param id document id
   * @returns
   */
  static async delete(id: string) {
    // console.log(id);
    const result = await this.client.collections(this.collection
      ).documents(id).delete();
    return result;
  }
}

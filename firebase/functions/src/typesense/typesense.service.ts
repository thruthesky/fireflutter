import { typesenseApiKey, typesenseHost, typesensePort, typesenseProtocol } from "../key";
import { TypesenseUser } from "./typesense.interface";
import * as Typesense from "typesense";


/**
 * Typesense Service
 *
 * This service is responsible for all the Typesense related operations.
 */
export class TypesenseService {
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
      logLevel: "debug",
    });
  }
  /**
   *
   * @param {TypesenseUser} user
   * @returns
   */
  static async upsertUser(user: TypesenseUser) {
    console.log(user);

    const result = await this.client
      .collections("testSearch")
      .documents().upsert(user);

    return result;
  }


  /**
   * delete typesense document
   *
   * @param id document id
   * @returns
   */
  static async delete(id: string) {
    console.log(id);
    return null;
  }
}

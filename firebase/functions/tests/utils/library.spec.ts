import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { expect } from "chai";
// import { Utils } from "../../src/utils/utils";
import { CallableError, invalidArgument } from "../../src/utils/library";
import { HttpsError } from "firebase-functions/v1/auth";

new FirebaseAppInitializer();

describe("Library", () => {
  it("invalidArgument", async () => {
    const res = invalidArgument("abc");
    expect(res.code).equals(CallableError.invalidArgument);
  });
  it("invalidArgument with details", async () => {
    const res: HttpsError = invalidArgument("abc", { message: "is abc" });
    expect(res.details).haveOwnProperty("message").equals("is abc");
  });
});

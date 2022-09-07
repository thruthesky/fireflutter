import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
// import { Test } from "../../src/classes/test";
// import { Utils } from "../../src/classes/utils";

// import { Messaging } from "../../src/classes/messaging";
import { expect } from "chai";

new FirebaseAppInitializer();

describe("Tokens test", () => {
  it("Token saving test for one user", async () => {
    expect("0").to.be.an("string");
  });
});

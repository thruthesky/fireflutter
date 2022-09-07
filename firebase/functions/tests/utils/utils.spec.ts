import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
// import { Test } from "../../src/classes/test";
// import { Utils } from "../../src/classes/utils";

// import { Messaging } from "../../src/classes/messaging";
import { expect } from "chai";
import { Utils } from "../../src/utils/utils";

new FirebaseAppInitializer();

describe("Utils", () => {
  it("Utils.getToday", async () => {
    expect(Utils.getToday()).to.be.an("string");
  });
});

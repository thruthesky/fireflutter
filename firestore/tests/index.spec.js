const assert = require("assert");
const { db, a, b, c, d, tempChatRoomData, admin } = require("./setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Rule tests", () => {
  it("onlyUpdating", async () => {
    await firebase.assertFails(
      db(c).collection("easy-commands").add({ c: "cherry" })
    );
    await firebase.assertSucceeds(
      db(a).collection("easy-commands").add({ a: "apple" })
    );
  });
});

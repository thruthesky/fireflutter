const assert = require("assert");
const {
    db,
    a,
    b,
    c,
    d,
    postsColName,
} = require("../setup");


// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Post Viewing Test", () => {
    it("Anyone can view posts list", async () => {
        await firebase.assertSucceeds(
            db(a)
                .collection(postsColName).get()
        );
    });
});
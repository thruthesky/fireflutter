const assert = require("assert");
const {
    db,
    a,
    b,
    c,
    d,
    commentsColsName,
    admin,
} = require("../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Comments View Test (comments-view.spec.js)", () => {
    it("Anyone can see comments", async () => {
        await firebase.assertSucceeds(
            db(a)
                .collection(commentsColsName).get()
        );
    });
});
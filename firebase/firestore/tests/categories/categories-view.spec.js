const assert = require("assert");
const {
    db,
    a,
    b,
    c,
    d,
    categoriesColName,
} = require("./../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Categories Viewing Test", () => {
    it("Anyone can view categories list", async () => {
        await firebase.assertSucceeds(
            db(a)
                .collection(categoriesColName).get()
        );
    });
});
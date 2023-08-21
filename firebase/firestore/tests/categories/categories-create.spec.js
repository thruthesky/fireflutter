const assert = require("assert");
const {
    db,
    a,
    b,
    c,
    d,
    categoriesColName,
    admin,
} = require("../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Categories Create Test", () => {
    it("Admin can add category - success", async () => {
        await firebase.assertSucceeds(
            admin().collection(categoriesColName).add({
                'name': 'Test',
                'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
                'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
                'createdBy': 'test-uid-admin',
            })
        );
    });
    it("Non-Admin CANNOT add category - failure", async () => {
        await firebase.assertFails(
            db(a).collection(categoriesColName).add({
                'name': 'Non Admin Test',
                'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
                'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
                'createdBy': a.uid,
            })
        );
    });
});
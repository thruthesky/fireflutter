const assert = require("assert");
const {
    db,
    a,
    b,
    c,
    d,
    categoriesColName,
    admin,
} = require("./../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Categories Delete Test", () => {
    it("Admin Cannot delete category - success", async () => {

        // Prepare
        const categoryRef = await admin().collection(categoriesColName).add({
            'name': 'Test',
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'createdBy': 'test-uid-admin',
        });

        // Admin tries to delete the category - succeeds (for confirmation)
        await firebase.assertSucceeds(
            admin().collection(categoriesColName).doc(categoryRef.id).delete()
        );
    });
    it("Non-Admin CANNOT delete category - failure", async () => {

        // Prepare
        const categoryRef = await admin().collection(categoriesColName).add({
            'name': 'Test',
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'createdBy': 'test-uid-admin',
        });

        // Non-Admin tries to delete the category - failure
        await firebase.assertFails(
            db(a).collection(categoriesColName).doc(categoryRef.id).delete()
        );
    });
});
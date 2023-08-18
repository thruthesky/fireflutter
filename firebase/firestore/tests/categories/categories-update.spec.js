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

describe("Categories Update Test", () => {
    it("Admin can update category - success", async () => {

        // Prepare
        const categoryRef = await admin().collection(categoriesColName).add({
            'name': 'Test',
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'addedBy': 'test-uid-admin',
        });

        // Admin Updates the category
        await firebase.assertSucceeds(
            admin().collection(categoriesColName).doc(categoryRef.id).update({
                'name': 'updated Name',
                'description': 'updated description',
                'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            })
        );
    });
    it("Non-Admin CANNOT add category - failure", async () => {

        // prepare
        const categoryRef = await admin().collection(categoriesColName).add({
            'name': 'Test',
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'addedBy': 'test-uid-admin',
        });

        // Non Admin tried to update category - fail
        await firebase.assertFails(
            db(a).collection(categoriesColName).doc(categoryRef.id).update({
                'name': 'updated Name',
                'description': 'updated description',
                'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            })
        );
    });
});
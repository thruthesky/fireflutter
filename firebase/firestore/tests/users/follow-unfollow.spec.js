const assert = require("assert");
const {
    db,
    a,
    b,
    c,
    d,
    usersColName,
    admin,
    editUser,
} = require("../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("User Follow/Unfollow Test (follow-unfollow.spec.js)", () => {
    it("User A follow B - successful", async () => {
        // Prepare user records
        await editUser(a);
        await editUser(b);
        // A follows B
        await firebase.assertSucceeds(
            db(a).collection(usersColName).doc(b.uid).update({
                followers: firebase.firestore.FieldValue.arrayUnion(a.uid),
            })
        );
    });

    // it("User A follow B - failure since he is already following?", async () => {
    //     // Prepare user records
    //     await editUser(a);
    //     await editUser(b);
    //     // A follows B
    //     await firebase.assertSucceeds(
    //         db(a).collection(usersColName).doc(b.uid).update({
    //             followers: firebase.firestore.FieldValue.arrayUnion(a.uid),
    //         })
    //     );
    //     await firebase.assertSucceeds(
    //         db(a).collection(usersColName).doc(b.uid).update({
    //             followers: firebase.firestore.FieldValue.arrayUnion(a.uid),
    //         })
    //     );
    // });




    it("User A asigned C as follower by B - failure", async () => {
        // Prepare user records
        editUser(a);
        editUser(b);
        editUser(c);
        // A assigned C to follow B
        await firebase.assertFails(
            db(a).collection(usersColName).doc(b.uid).update({
                followers: firebase.firestore.FieldValue.arrayUnion(c.uid),
            })
        );
    });
    it("User A unfollow B - successful", async () => {
        // Prepare user records
        editUser(a);
        editUser(b);
        // A follows B
        await db(a).collection(usersColName).doc(b.uid).update({
            followers: firebase.firestore.FieldValue.arrayUnion(a.uid),
        });
        // A unfollows B
        await firebase.assertSucceeds(
            db(a).collection(usersColName).doc(b.uid).update({
                followers: firebase.firestore.FieldValue.arrayRemove(a.uid),
            })
        );
    });
    it("User A forced C to unfollow B - failure", async () => {
        // Prepare user records
        editUser(a);
        editUser(b);
        editUser(c);
        // C follows B
        await db(c).collection(usersColName).doc(b.uid).update({
            followers: firebase.firestore.FieldValue.arrayUnion(c.uid),
        });
        // A force C to unfollow B
        await firebase.assertFails(
            db(a).collection(usersColName).doc(b.uid).update({
                followers: firebase.firestore.FieldValue.arrayRemove(c.uid),
            })
        );
    });

});
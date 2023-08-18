const assert = require("assert");
const { db, a, b, c, tempChatRoomData, createChatRoom } = require("./../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Chat room read test", () => {
    it("Read chat room that user is NOT a member - failure ", async () => {
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid, b.uid] });

        await firebase.assertFails(
            db(c)
                .collection("easychat")
                .doc(roomRef.id)
                .get()
        );
    });

    it("Read chat room that user is a member - success ", async () => {
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid, b.uid] });

        await firebase.assertSucceeds(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .get()
        );
    });

    // it("Read chat room that does NOT exist - success ", async () => {
    //     await firebase.assertSucceeds(await db(b)
    //         .collection("easychat")
    //         .doc('nonexistingroom')
    //         .get()
    //     );
    // });

    it("Read chat room that exist but NOT room user - failure ", async () => {
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid, b.uid] });
        await firebase.assertFails(
            db(c)
                .collection("easychat")
                .doc(roomRef.id)
                .get()
        );
    });

    it("Read Open Group Chat Room by user who does not belong to the room - success", async () => {
        // user A created a Room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid], open: true, group: true });
        // user B reads the Room
        await firebase.assertSucceeds(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .get()
        );
    });

    it("Read Closed Group Chat Room by user who does not belong to the room - failure", async () => {
        // user A created a Room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid], open: false, group: true });
        // user B reads the Room
        await firebase.assertFails(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .get()
        );
    });

    it("Read Open Group Chat Room by user who does belong to the room - success", async () => {
        // user A created a Room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid], open: true, group: true });
        // user A reads the Room
        await firebase.assertSucceeds(
            db(a)
                .collection("easychat")
                .doc(roomRef.id)
                .get()
        );
    });

    it("Read Closed Group Chat Room by user who does belong to the room - success", async () => {
        // user A created a Room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid], open: false, group: true });
        // user A reads the Room
        await firebase.assertSucceeds(
            db(a)
                .collection("easychat")
                .doc(roomRef.id)
                .get()
        );
    });

    it("Read Closed Group Chat Room by user who is just invited to the room - success", async () => {
        // user A created a Room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid], open: false, group: true });
        // user B reads the Room
        await firebase.assertFails(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .get()
        );
        // user A invited user B
        await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .update({ users: firebase.firestore.FieldValue.arrayUnion(b.uid) });
        // user B reads the Room after invitation
        await firebase.assertSucceeds(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .get()
        );
    });

    it("Read Closed Group Chat Room by user who is just kicked out to the room - failure", async () => {
        // user A created a Room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid], open: false, group: true });
        // user B reads the Room
        await firebase.assertFails(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .get()
        );
        // user A invited user B
        await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .update({ users: firebase.firestore.FieldValue.arrayUnion(b.uid) });
        // user B reads the Room after invitation
        await firebase.assertSucceeds(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .get()
        );
        // user A kicked out user B
        await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .update({ users: firebase.firestore.FieldValue.arrayRemove(b.uid) });
        // user B reads the Room after kickout
        await firebase.assertFails(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .get()
        );
    });
});





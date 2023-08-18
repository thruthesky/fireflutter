const assert = require("assert");
const {
    db,
    a,
    b,
    c,
    d,
    createChatRoom,
    createOpenGroupChat,
    tempChatRoomData,
    invite,
    block,
    setAsModerator,
} = require("./../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Chat Room Password Update test", () => {
    it("There is no default password", async () => {

        // PREPARE: Create chat room by A
        const roomRef = await createOpenGroupChat(a);

        // get room details
        const roomDoc = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();

        // There must be no password
        assert.ok(roomDoc.data().password == null);
    });
    it("Master updates the room password - successful", async () => {
        // PREPARE: Create chat room by A
        const roomRef = await createOpenGroupChat(a);

        // Master A updates the password
        const password = 'samplepassword';
        await firebase.assertSucceeds(
            db(a)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ password: password })
        );

        // get room details
        const roomDoc = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();

        // Password must be updated
        assert.ok(roomDoc.data().password == password);
    });
    it("Moderator updates the room password - passed", async () => {
        // PREPARE: Create chat room by A
        const roomRef = await createOpenGroupChat(a);

        // A invites B
        await invite(a, b, roomRef.id);

        // A assigned B as moderator
        await setAsModerator(a, b, roomRef.id);

        // Moderator B updates the password
        const password = 'samplepassword';
        await firebase.assertSucceeds(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ password: password })
        );

        // get room details
        const roomDoc = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();

        // Password must be updated
        assert.ok(roomDoc.data().password == password);
    });
    it("Regular Member updates the room password - failure", async () => {
        // PREPARE: Create chat room by A
        const roomRef = await createOpenGroupChat(a);

        // A invites B
        await invite(a, b, roomRef.id);


        // Moderator B updates the password
        const password = 'samplepassword';
        await firebase.assertFails(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ password: password })
        );

        // get room details
        const roomDoc = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();

        // There must be no password
        assert.ok(!(roomDoc.data().password == password));
    });
});
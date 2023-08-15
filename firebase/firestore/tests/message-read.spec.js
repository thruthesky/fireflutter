const assert = require("assert");
const { db, a, b, c, tempChatRoomData, createChatRoom, createOpenGroupChat, invite, block } = require("./setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Message read test", () => {
    it("Read a message by NOT a chat room user - failure ", async () => {
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid, b.uid] });

        await firebase.assertFails(
            db(c)
                .collection("easychat")
                .doc(roomRef.id)
                .collection("messages")
                .get()
        );
    });

    it("Read mesage by user in the chat room - success ", async () => {
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid, b.uid] });

        await firebase.assertSucceeds(
            db(a)
                .collection("easychat")
                .doc(roomRef.id)
                .collection("messages")
                .get()
        );
        await firebase.assertSucceeds(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .collection("messages")
                .get()
        );
    });

    it("Read mesages when blocked - failure ", async () => {
        // PREPARE
        const roomRef = await createOpenGroupChat(a);

        // Master A inviting B
        await invite(a, b, roomRef.id);


        // A blocks B
        await firebase.assertSucceeds(block(a, b, roomRef.id));

        // B reads messages ---> failure
        await firebase.assertFails(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .collection("messages")
                .get()
        );
    });

    it("Read mesages when someone else is blocked - success ", async () => {
        // PREPARE
        const roomRef = await createOpenGroupChat(a);

        // Master A inviting B
        await invite(a, b, roomRef.id);

        // Master A inviting C
        await invite(a, c, roomRef.id);

        // A blocks B
        await firebase.assertSucceeds(block(a, b, roomRef.id));

        // C reads messages ---> success
        await firebase.assertSucceeds(
            db(c)
                .collection("easychat")
                .doc(roomRef.id)
                .collection("messages")
                .get()
        );
    });

});


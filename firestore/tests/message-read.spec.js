const assert = require("assert");
const { db, a, b, c, tempChatRoomData, createChatRoom } = require("./setup");

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

});


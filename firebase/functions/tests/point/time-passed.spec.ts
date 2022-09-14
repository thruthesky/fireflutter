// import "mocha";
// import * as admin from "firebase-admin";

// import { FirebaseAppInitializer } from "../firebase-app-initializer";

// import { expect } from "chai";
// import { Point } from "../../src/classes/point";
// import { EventName, pointEvent } from "../../src/interfaces/point.interface";
// import { Utils } from "../../src/utils/utils";

// new FirebaseAppInitializer();

// describe("Point", () => {
//   it("Point.timePassed() to be true", async () => {
//     const re = await Point.timePassed(new admin.firestore.Timestamp(1, 2), EventName.postCreate);
//     expect(re).equals(true);
//   });

//   it("Point.timePassed() to be false on the same time(seconds) of createAt and deadline", async () => {
//     const within = pointEvent[EventName.postCreate].within;
//     const shouldBeFalse = await Point.timePassed(
//       new admin.firestore.Timestamp(Utils.getTimestamp() - within, 0),
//       EventName.postCreate
//     );

//     expect(shouldBeFalse).equals(false);
//   });

//   it("Point.timePassed() to be true on 1 second passed", async () => {
//     const within = pointEvent[EventName.postCreate].within;
//     const shouldBeTrue = await Point.timePassed(
//       new admin.firestore.Timestamp(Utils.getTimestamp() - within - 1, 0),
//       EventName.postCreate
//     );

//     expect(shouldBeTrue).equals(true);
//   });

//   it("Point.timePassed() to be false after 7 days.", async () => {
//     const re = await Point.timePassed(
//       new admin.firestore.Timestamp(Utils.getTimestamp() + 60 * 60 * 24 * 7, 2),
//       EventName.postCreate
//     );
//     expect(re).equals(false);
//   });
// });

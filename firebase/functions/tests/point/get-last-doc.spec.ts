import "mocha";
import * as admin from "firebase-admin";

import { FirebaseAppInitializer } from "../firebase-app-initializer";

import { expect } from "chai";
import { Point } from "../../src/classes/point";
import { EventName } from "../../src/interfaces/point.interface";
import { Utils } from "../../src/utils/utils";
import { Ref } from "../../src/utils/ref";

new FirebaseAppInitializer();

describe("Point", () => {
  it("Get last doc", async () => {
    await Ref.pointHistoryCol("a").add({
      eventName: EventName.postCreate,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await Utils.delay(100);

    await Ref.pointHistoryCol("a").add({
      eventName: EventName.postCreate,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await Ref.pointHistoryCol("b").add({
      eventName: EventName.commentCreate,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await Ref.pointHistoryCol("c").add({
      eventName: EventName.postCreate,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const doc = await Point.getLastDoc("a", EventName.postCreate);
    // console.log(doc);
    expect(doc).to.be.an("object");

    const shouldBeNull = await Point.getLastDoc("non-existsing-user", EventName.postCreate);
    expect(shouldBeNull).to.be.null;

    const shouldBeAnotherNull = await Point.getLastDoc("a", "non-existing-event-name");
    expect(shouldBeAnotherNull).to.be.null;
  });
});

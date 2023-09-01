import "mocha";
import { expect } from "chai";

import "../firebase.init";
import { Upload } from "../../src/models/upload.model";

describe("Storage", () => {
  it("update target reference", async () => {
    Upload.setReference(
      [
        "https://firebasestorage.googleapis.com/v0/b/withcenter-kmeet.appspot.com/o/users%2FmdpJvOjfn4VIoa2gbFoxnzBmMuN2%2Fuploads%2F1669966506981000.jpg?alt=media&token=e0899484-a5da-4fac-b47e-97ff1503090d",
        "https://firebasestorage.googleapis.com/v0/b/withcenter-kmeet.appspot.com/o/users%2FmdpJvOjfn4VIoa2gbFoxnzBmMuN2%2Fuploads%2F1669966515238000.jpg?alt=media&token=6c18ce89-64d2-419e-b2b6-f89461c6b9c2",
        "https://firebasestorage.googleapis.com/v0/b/withcenter-kmeet.appspot.com/o/users%2FmdpJvOjfn4VIoa2gbFoxnzBmMuN2%2Fuploads%2F1669966519486000.jpg?alt=media&token=57c33da0-4a0b-4aa8-81ed-7a6cf68b408d",
      ],
      "/posts/9OVt9z90vArpitVHuUzS",
      "profilePhoto"
    );

    expect(true).eq(true);
  });
});

export class Test {
  static testCount = 0;

  // one push token.
  static token =
    "d-RUY7gztE1wnheilIWUYC:APA91bE_owxgKAYy7808o5EFFSKhyle5jpv9-tcfX2_KPh1rgrzh58K4erUwO1mk7bea6FVoksyH7ouACZjr0kA_kYe0X8uUergnAeS85UEBL3u7CxEC4sg3jRXLhGu2FdRKnqfuV0Ya";

  static jaehoSimulatorToken =
    "cVdUO22hkEd-rhGvagjHMJ:APA91bG5656PPaKawRSIQsN_gfqUqTd4CFCxmF7RcdvTlwqHjejCVTcILZMnl_RepEpg6mJn2MTc4dBAncv7bMB4Y5cEkqVCXH3ybgObsPlcoOJAqsz1xxoe_qR57t3gaN6ssDhKAmP3";
  // three push tokens. two are real. one is fake.
  static tokens = ["fake-token"];

  /**
   * Create a user for test
   *
   * It creates a user document under /users/<uid> with user data and returns user ref.
   *
   * @param {*} uid
   * @return - reference of newly created user's document.
   *
   * @example create a user.
   * test.createTestUser(userA).then((v) => console.log(v));
   */
  static async createTestUser(uid: string, data?: any) {
    // check if the user of uid exists, then return null
    console.log(uid, data);
  }
}

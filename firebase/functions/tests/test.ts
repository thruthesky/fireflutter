export class Test {
  static testCount = 0;

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

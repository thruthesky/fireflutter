// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

// Firebase project that the tests connect to.
const TEST_PROJECT_ID = "withcenter-test-2";

const a = { uid: "uid-A", email: "apple@gmail.com" };
const b = { uid: "uid-B", email: "banana@gmail.com" };
const c = { uid: "uid-C", email: "cherry@gmail.com" };
const d = { uid: "uid-D", email: "durian@gmail.com" };

const postsColName = "posts";
const categoriesColName = "categories";
const chatsColName = "chats";

// Connect to Firestore with a user permission.
function db(auth = null) {
  return firebase
    .initializeTestApp({ projectId: TEST_PROJECT_ID, auth: auth })
    .firestore();
}

// Connect to Firestore with admin permssion. This will pass all the rules.
function admin() {
  return firebase
    .initializeAdminApp({ projectId: TEST_PROJECT_ID })
    .firestore();
}

/**
 * Returns fake chat room data
 *
 *
 * By default,
 *  - createdAt: new Date()
 *  - group: false
 *  - open: false
 *  - no uid.
 *
 *
 * @param {*} options
 * @returns returns chat room data
 *
 * @example
 *  - tempChatRoomData({ master: a.uid, users: [a.uid, b.uid] }
 */
function tempChatRoomData(options = {}) {
  return Object.assign(
    {},
    {
      createdAt: new Date(),
      group: false,
      open: false,
    },
    options
  );
}

/**
 *
 * @param {*} masterAuth
 * @param {*} options
 * @returns chat room ref
 * @example
 * - const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid, b.uid] });
 */
function createChatRoom(masterAuth, options = {}) {
  return db(masterAuth).collection(chatsColName).add(tempChatRoomData(options));
}

async function createOpenGroupChat(masterAuth) {
  return await createChatRoom(a, {
    master: a.uid,
    users: [a.uid],
    open: true,
    group: true,
  });
}

/**
 * Chat invite
 *
 *
 * @param {*} a the auth of the user who invites
 * @param {*} b the auth of the user who is being invited.
 */
async function invite(a, b, roomId) {
  await db(a)
    .collection(chatsColName)
    .doc(roomId)
    .update({ users: firebase.firestore.FieldValue.arrayUnion(b.uid) });
}

/**
 * Chat block
 *
 *
 * @param {*} blockerAuth the auth of the user who blocks
 * @param {*} blockedAuth the auth of the user who is being blocked.
 */
async function block(blockerAuth, blockedAuth, roomId) {
  await db(blockerAuth)
    .collection(chatsColName)
    .doc(roomId)
    .update({
      blockedUsers: firebase.firestore.FieldValue.arrayUnion(blockedAuth.uid),
    });
}

/**
 * Chat unblock
 *
 *
 * @param {*} unblockerAuth the auth of the user who blocks
 * @param {*} blockedAuth the auth of the user who is being blocked.
 */
async function unblock(unblockerAuth, blockedAuth, roomId) {
  await db(unblockerAuth)
    .collection(chatsColName)
    .doc(roomId)
    .update({
      blockedUsers: firebase.firestore.FieldValue.arrayRemove(blockedAuth.uid),
    });
}

/**
 * Chat Set as Moderator
 *
 *
 * @param {*} setterAuth the auth of the user who sets the moderator
 * @param {*} userAuth the auth of the user who is being added as moderator.
 */
async function setAsModerator(setterAuth, userAuth, roomId) {
  await db(setterAuth)
    .collection(chatsColName)
    .doc(roomId)
    .update({
      moderators: firebase.firestore.FieldValue.arrayUnion(userAuth.uid),
    });
}

async function createCategory() {
  const id = "test-category" + Date.now();

  console.log(categoriesColName, id);

  // create category
  await admin().collection(categoriesColName).doc(id).set({
    name: id,
    createdAt: firebase.firestore.FieldValue.serverTimestamp(),
    updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
    // TODO - change addBy to uid.
    addedBy: "test-uid-admin",
  });

  return admin().collection(categoriesColName).doc(id);
}

// create post
async function createPost(options = {}) {
  if (!options.auth) {
    options.auth = a;
  }
  const categoryRef = await createCategory();

  // create post
  const postRef = await db(options.auth).collection(postsColName).add({
    categoryId: categoryRef.id,
    title: "Sample Title",
    content: "Sample Content",
    uid: options.auth.uid,
    createdAt: firebase.firestore.FieldValue.serverTimestamp(),
    updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
    likes: [],
  });

  return postRef;
}

exports.db = db;
exports.admin = admin;
exports.tempChatRoomData = tempChatRoomData;
exports.createChatRoom = createChatRoom;
exports.a = a;
exports.b = b;
exports.c = c;
exports.d = d;
exports.postsColName = postsColName;
exports.categoriesColName = categoriesColName;
exports.chatsColName = chatsColName;
exports.TEST_PROJECT_ID = TEST_PROJECT_ID;
exports.createOpenGroupChat = createOpenGroupChat;
exports.invite = invite;
exports.block = block;
exports.unblock = unblock;
exports.setAsModerator = setAsModerator;
exports.createCategory = createCategory;
exports.createPost = createPost;



/**
 * Random String generator
 * @returns String
 */
export function randomString(): string {
    return Math.random().toString(36).slice(2, 22);
}

/**
 * Generates random user
 */
// export function generateUser(): TypesenseDoc {
//     const uid = randomString();
//     return {
//         id: uid,
//         type: "user",
//         uid: uid,
//         displayName: "name-" + uid,
//         createdAt: 12345,
//     };
// }

// /**
//  * Generates random post doc
//  */
// export function generatePost(): TypesenseDoc {
//   return {
//     // id: id,
//     type: "post",
//     title: "title-post",
//     content: "content-post",
//     // category: "category",
//     noOfLikes: 1,
//     noOfCommments: 1,
//     deleted: false,
//     createdAt: 12345,
//   };
// }

// /**
//  * Generates a comment doc
//  * @returns TypesenseDoc
//  */
// export function generateComment(): TypesenseDoc {
//   const id = randomString();
//   const uid = randomString();
//   const postId = randomString();
//   return {
//     id: id,
//     type: "comment",
//     content: "content-" + id,
//     uid: uid,
//     postId: postId,
//     deleted: false,
//     createdAt: 12345,
//   };
// }


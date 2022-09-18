import * as functions from "firebase-functions";
import { Post } from "../classes/post";
import { cors } from "../utils/cors";

export const post = functions.region("asia-northeast3").https.onRequest((req, res) => {
  cors({ req, res }, async (data) => {
    res.status(200).send(await Post.get(data.id));
  });
});

export const posts = functions.region("asia-northeast3").https.onRequest((req, res) => {
  cors({ req, res }, async (data) => {
    res.status(200).send(await Post.posts(data));
  });
});

# 클라우드 함수



I thought that I will not use Firebase cloud functions since it is a bit difficult to maintain the code. And we already have all the neccessary code in Flutter. But the code in the Flutter is not efficient. For instance, sending push notifications for a group chat from the Flutter app can downgrade the performance seriously. Even if the work is done in isolated, still it will consume a hugh resource. I am expecing that there are more than 1,000 uesrs who are chatting a lot every day. That's what acctually happens. And every time a user send a message, the push message ... (I will not explain it details.)

So, the app should not do this work from the Flutter app. You may send the push notification from client only if it will not consume a lot of resource.

And here comes the cloud functions

## Sending push notificaiton on each chat message

## Sending push notification on post and comment create

## Indexing data into typesense

## indexing post data issues

- When ever comment is created/updated/deleted, the post write event trigger unneccessarily causing extra function call, document read(including all the comments), and band width, and unneccessary typesense indexing. As of now, we just let it be this way. This is the cheapest for now.

## Post Summaries upon Post Create/Update/Delete

- We have cloud functions that whenever a post is created/updated/deleted in `posts`, it updates `post-all-summaries` and `post-summaries`.

### managePostsAllSummary

This cloud function updates `post-all-summaries` and `post-summaries` based on `posts`.

Be informed that we are only saving the first url of the post in summaries.


## 사용자 클라우드 함수

참고, [사용자 문서](#user.md)를 문서를 참고한다.
참고, `user.functions.ts` 를 살펴 본다.

클라우드 함수는 사용자 기능을 좀 더 보강하기 위해서 여러가지 함수를 제공하고 있으며, 필요한 것만 설치를 해서 사용하면 된다.

- `userLike` 는 A 가 B 를 좋아요 할 때, B 가 A 를 좋아요 하고 있다고 알려주어야 하며, 총 좋아요 갯 수도 증/감 시켜 주어야 한다. 이러한 잡다한 일을 `userLike` 가 해 준다.

- `userMirror` 는 rtdb 의 `/users` 노드 값을 firestore 의 `/users` 컬렉션으로 이동 시켜준다. 이렇게 하므로서, 사용자 검색을 보다 복잡하게 할 필요가 있는 경우, firestore 를 통해서 필터링해서 화면에 보여주면 된다. 이 때, 한가지 주의 할 점은 `noOfLikes` 필드는 mirror 하지 않는데 그 이유는 사용자 목록에서 좋아요/좋아요취소 를 하는 경우, rtdb 의 `/users/<uid>/noOfLikes` 가 증/감하면 firestore 의 `/users` 데이터 값이 변경된다. 만약, FirestoreListView 와 같이 쿼리를 통해서 사용자 필터링을 하는 경우, 사용자의 문서가 하나 변경되면, 모든 목록(검색되는 아이템)이 다시 그려져야하는데, 이 때 화면 반짝임이 발생하기 때문이다.

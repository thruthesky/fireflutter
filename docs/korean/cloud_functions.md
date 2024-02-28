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



## 전화번호 가입

전화번호 가입을 하는 함수는 다음과 같은 이유로 만들어 졌다.

```txt
노인들을 위한 앱을 만드는데, 노인들은 회원 가입을 매우 어려워한다. 전화번호 인증을 하면 문자를 확인해서 입력하기 어렵고, 비밀번호를 지정하면 비밀번호를 만드는것과 외우지 못해서 나중에 까먹어 버리는 경우가 발생한다. 그래서, 전화번호만 입력하면 곧 바로 가입이 되게 하는 것이다. 만약, 전화번호가 이미 가입되어져 있는데, 가입을 하려면 그때에는 전화번호 인증을 하게 한다. 즉, 첫번째 로그인은 문자 인증 없이 가입. 두번째 로그인은 문자 인증을 해서 가입을 하는 것이다.
```

요청을 할 때에는 `phoneNumber` 에 가입할 전화번호를 입력하면 된다. 전화번호가 입력되지 않거나, 너무 짧거나, 긴 경우는 함수에서 에러를 낸다. 그 외에는 Firebase 에서 에러를 낸다.
전화번호는 국제 전화번호 포멧에 맞아야 한다.


- 요청: `?phoneNumber=12345`
  - 결과: `{ code: 'auth/invalid-phone-number', message: '...' }`
- 요청: `?phoneNumber=1234567890123456`
  - 결과: `{ code: 'auth/invalid-phone-number', message: '...' }`
- 요청: `/?phoneNumber=1234567890`
  - 결과: `{ code: 'auth/invalid-phone-number', message: '...' }`

- 전화번호가 존재하는 경우, `{ code: 'auth/phone-number-already-exists', message: '...' }` 와 같이 에러가 나온다.

- 성공하는 경우
  - 결과: `{ uid: 'YSr8fJwQASSF4QApILkaAEjbfCd2' }`


참고로, 클라우드 함수 호출이 속도가 좀 느린편이다. 그나마 맨 처음 (새로운) 전화번호를 입력해서 가입을 할 때에는 Firebase Phone Sign-in 과정이 없어서 조금은 빨리 로그인이 되지만, 두번째 로그인을 할 때에는 Phone Sign-in 을 해야 해서 로그인 속도가 좀 더 느릴 수 있다.



## 함수 테스트

[테스트 문서](./test.md)를 참고한다.

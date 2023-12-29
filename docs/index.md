# Fireship

파이어베이스 Realtime Database 를 바타응로 실시간 콘텐츠 관리를 위한 빠르고 강력한 플러터 CMS 라이브러리입니다.





## 데이터베이스


- Realtime Database 위주로 사용을 하는데, 가장 큰 이유는 속도 때문이다. 물론 부가적으로 비용을 절감을 할 수 있다. 그러나, Firestore 보다는 검색 필터링 옵션이 부족하므로, 필요에 따라서 Firestore 에 데이터를 나누어 저장 할 필요가 있다.


- 데이터베이스 node 에서 여러 단어가 들어가는 경우, `-` 로 구분 짓는다. 예, `user-photos`


### 사용자 정보

- `/users/<uid>` 에 저장
  - `createdAt` 은 처음 로그인 시간



- `/user-photos/<uid>` 는 사용자가 프로필 사진을 업로드 할 때 마다 갱신된다.
  - `{updatedAt: ..., photoUrl: ...}` 와 같은 값이 저장된다. 이를 바탕으로 최근에 사진을 변경한 사용자 순서로 목록 할 수 있다.
  - 회원이 사진을 업로드/삭제 할 때, `UserModel` 내에서 자동으로 처리된다.




## 소팅 / 정렬

정렬을 할 때에 정렬 필드와 값을 별도의 node 에 저장한다. 예를 들어, 사진을 업로드한 사용자 목록을 가입날짜 순 또는 사용자 사진을 변경한 순서로 목록하고 싶다면,

- DB 구조 예
  - 아래와 같이 하면, 사용자가 사진을 수정한 날짜 순서로 회원 사진이 있는 사용자만 목록 할 수 있다.

`/user-photos/<uid>/ { updatedAt: ..., photoUrl: ... }`




## 디자인 컨셉



## Messaging

As the deprecation of [Send messages to multiple devices](https://firebase.google.com/docs/cloud-messaging/send-message#send-messages-to-multiple-devices) is stated in the [official Firebase Documentation](Send messages to multiple devices), we will send push notifications in Flutter code.




## 썸네일

- 썸네일을 사용하지 않는다. 과거에는 Firebase Extensions 의 Resize Image 를 통해서 썸네일 이미지를 사용했는데, 이미지를 업로드 할 때, compression 을 하므로, 이미지 용량이 그다지 크지 않다. 평균적으로 3M ~ 5M 사이즈 이미지를 업로드하면, 클라이언트 앱에서 200Kb ~ 300Kb 용량으로 줄여서 업로드를 한다.




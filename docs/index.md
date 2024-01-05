# Fireship

파이어베이스 Realtime Database 를 바타응로 실시간 콘텐츠 관리를 위한 빠르고 강력한 플러터 CMS 라이브러리입니다.

## 설치

See install.md

## 데이터베이스

참고: [데이터베이스](database.md)

## 사용자

참고: [사용자 개발 매뉴얼](user.md)

## 소팅 / 정렬

정렬을 할 때에 정렬 필드와 값을 별도의 node 에 저장한다. 예를 들어, 사진을 업로드한 사용자 목록을 가입날짜 순 또는 사용자 사진을 변경한 순서로 목록하고 싶다면,

- DB 구조 예
  - 아래와 같이 하면, 사용자가 사진을 수정한 날짜 순서로 회원 사진이 있는 사용자만 목록 할 수 있다.

`/user-profile-photos/<uid>/ { updatedAt: ..., photoUrl: ... }`

## 디자인 컨셉

### UI 디자인 커스터마이징

Fireship 은 기본적으로 디자인을 제공하며, 모두 변경이 가능하다.

앱의 여러 곳에서 사용자 프로필을 보기를 원 할 수 있다. 예를 들면, 채팅방안에서, 사용자 목록에서, 게시판 글/코멘트에서 사용자 사진을 클릭하는 경우 사용자 공개 프로필을 보여 줄 수 있다. 이 때, 통일되게 `UserService.instance.showPublicProfile(uid: ...)` 함수 하나만 호출하면 어디서든 해당 사용자의 프로필을 보여 줄 수 있다.

만약, 기본 디자인이 아닌 직접 디자인을 커스터마이징을 하고 싶으면, `UserSerivce.instance.init(customize: UserCustomize(...))` 를 통해서 커스터마이징을 하면 된다.

커스터마이징 가능한 위젯들의 이름은 `Default` 로 시작한다. 커스터마이징을 할 때에는 fireship 에 있는 코드를 그대로 복사해서 사용하면 된다.

## Messaging

As the deprecation of [Send messages to multiple devices](https://firebase.google.com/docs/cloud-messaging/send-message#send-messages-to-multiple-devices) is stated in the [official Firebase Documentation](Send messages to multiple devices), we will send push notifications in Flutter code.

## 썸네일

- 썸네일을 사용하지 않는다. 과거에는 Firebase Extensions 의 Resize Image 를 통해서 썸네일 이미지를 사용했는데, 이미지를 업로드 할 때, compression 을 하므로, 이미지 용량이 그다지 크지 않다. 평균적으로 3M ~ 5M 사이즈 이미지를 업로드하면, 클라이언트 앱에서 200Kb ~ 300Kb 용량으로 줄여서 업로드를 한다.

## 관리자

- [관리자 문서](admin.md) 참고

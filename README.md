# FireFlutter v0.3

[English version](README.en.md)


- [FireFlutter v0.3](#fireflutter-v03)
- [해야 할 것](#해야-할-것)
- [프로젝트 개요](#프로젝트-개요)
  - [이슈 및 문의](#이슈-및-문의)
  - [버전 업그레이드 진행 상황](#버전-업그레이드-진행-상황)
  - [데이터베이스 - Firestore 와 Realtime Database](#데이터베이스---firestore-와-realtime-database)
- [외부 패키지 목록](#외부-패키지-목록)
- [기능 별 데이터 구조](#기능-별-데이터-구조)
  - [사용자](#사용자)
    - [사용자 문서](#사용자-문서)
- [Fireflutter 초기화](#fireflutter-초기화)
- [사용자 로그인](#사용자-로그인)
  - [전화번호 로그인](#전화번호-로그인)
- [사용자 정보 보여주기](#사용자-정보-보여주기)
- [사진(파일) 업로드](#사진파일-업로드)
  - [업로드된 사진 보여주기](#업로드된-사진-보여주기)
- [사용자 설정](#사용자-설정)
  - [사용자 설정을 바탕으로 위젯을 보여주는 MySettingsBuilder](#사용자-설정을-바탕으로-위젯을-보여주는-mysettingsbuilder)
  - [사용자 설정 관련 코드](#사용자-설정-관련-코드)
    - [사용자 설정 관련 코드 예](#사용자-설정-관련-코드-예)
- [게시판 카테고리](#게시판-카테고리)
  - [CategoryService.instance.loadCategories()](#categoryserviceinstanceloadcategories)
  - [CategoryService.instance.getCategories()](#categoryserviceinstancegetcategories)
- [게시판 글](#게시판-글)
  - [글 생성](#글-생성)
    - [글 생성 로직 예](#글-생성-로직-예)
    - [글 생성 위젯 - PostForm](#글-생성-위젯---postform)
  - [글 가져오기](#글-가져오기)
  - [글 목록 가져오기](#글-목록-가져오기)
    - [글 목록을 무한 스크롤로 가져오기](#글-목록을-무한-스크롤로-가져오기)
- [푸시 알림](#푸시-알림)
  - [푸시 알림 관련 참고 문서](#푸시-알림-관련-참고-문서)
  - [푸시 알림 설정](#푸시-알림-설정)
    - [Android 설정](#android-설정)
    - [iOS 설정](#ios-설정)
  - [푸시 알림 문서 구조](#푸시-알림-문서-구조)
  - [푸시 알림 기능 초기화](#푸시-알림-기능-초기화)
  - [푸시 알림 구독과 구현 로직](#푸시-알림-구독과-구현-로직)
  - [푸시 알림 전송 - Push Notification 전송하기](#푸시-알림-전송---push-notification-전송하기)
    - [게시판 글, 코멘트 관련 푸시 자동 알림](#게시판-글-코멘트-관련-푸시-자동-알림)
    - [직접 푸시 알림 메시지 전송](#직접-푸시-알림-메시지-전송)
- [클라우드 함수](#클라우드-함수)
  - [FunctionsApi](#functionsapi)
  - [유닛 테스트](#유닛-테스트)
  - [클라우드 함수 Deploy](#클라우드-함수-deploy)
  - [플러터에서 클라우드 함수 호출](#플러터에서-클라우드-함수-호출)
  - [푸시 알림 사운드](#푸시-알림-사운드)
  - [클라우드 함수 설명](#클라우드-함수-설명)
    - [전화번호로 가입된 사용자 UID 찾기](#전화번호로-가입된-사용자-uid-찾기)
    - [posts 글 목록](#posts-글-목록)
    - [post 글 한 개 가져오기](#post-글-한-개-가져오기)
- [Firestore 보안 규칙](#firestore-보안-규칙)
  - [관리자 지정](#관리자-지정)
  - [게시판](#게시판)
- [에러 핸들링](#에러-핸들링)
- [Firestore 인덱싱](#firestore-인덱싱)
- [포인트와 레벨](#포인트와-레벨)
  - [포인트 설정](#포인트-설정)
  - [Common Fitfalls](#common-fitfalls)
- [위젯](#위젯)
  - [DocumentBuilder](#documentbuilder)
  - [Admin](#admin)
  - [RecentPostCard - 사진이 있는 최근 글 카드로 보여주기](#recentpostcard---사진이-있는-최근-글-카드로-보여주기)
- [실험 코드](#실험-코드)
- [문제 해결](#문제-해결)
  - [인덱스 문제](#인덱스-문제)


# 해야 할 것

- 보안 규칙 설명
- 게시판 보안 규칙

- orderby createdAt desc 로 할 때, category, hsaPhoto, deleted, month, uid 등으로 여러가지 인덱스가 생성 될 수 있다.
  - 인덱스가 200 개 제한이 있으므로, index merging 으로 해결을 한다.
- Cloud Functions 설명

- `ForumMixin` 을 `ForumService` 로 변경한다. 통일된 코딩 방식이 필요하다.
- `ChatMixin` 도 `ChatService` 로 변경한다.




- 관리자의 경우 글 쓰기 양식에서 Document ID 를 직접 지정하고, 활용 할 수 있도록 한다. 기능이 있지만 잘 동작하는 지 확인한다.

- 플러터코리아 앱을 https://flutterkorea.co.kr 로 연결하고, 최대한 빠르게 배포한다.
  - 그리고, FlutterFlow 로 연결해서, 강좌 앱을 만들도록 한다.

- Rich editor - https://github.com/tneotia/html-editor-enhanced 를 이용해서 빌드한다. Quill 보다는 HTML 편집기가 여러모로 낳을 것 같다.

- 푸시 알림을 본 문서의 [푸시 알림](#푸시-알림)에 나오는데로 수정한다.
  - 토픽 구독 없이, 토큰으로 모든 subscription 로직 작성.
  예를 들어, QnA subscribe 하면 환경 설정에만 기록하고, 토픽 구독하지 않는다. 그래서 QnA 에 새 글 이 있으면 해당 토픽을 subscribe 한 사용자의 uid 배열을 서버로 전달해서, 푸시를 보내도록 한다.
- 글 쓰기 등 권한이 필요한 경우, `FireFlutterService.instance.init(permission: (Permission p)) {}` 와 같이 해서, 프로필이 완료되었는지, 레벨이 되는지 등을 검사해서, 권한을 부여 할 수 있도록 한다.


- (다음버전) 전체 푸시 알림
  - 전체 푸시 알림은 `condition="!('nonExistingTopic' in topics)"`와 같은 방식으로 되지 않는다.
  - 다음 버전에서 업데이트 할 때, topic subscription 으로 해결 할 수 있다.
    - `/users/<uid>/fcm_tokens/<tokenId>` 를 `onWrite` 이벤트 trigger 를 통해서 `all`,`andriod`,`ios`,`web` 등의 토픽으로 자동 subscription 한다.
  - 또는 사용자의 모든 토큰을 읽어서 모든 토큰에 메시지를 보낼 수 있다. 하지만 조금 비 효율적이라는 판단이 든다. topic subscription 이 나아 보인다.

- (다음버전) 다음 글 쓰기 대기 시간. 예를 들어, buyandsell 게시판에 글을 한번 쓰면 60 분 또는 24 시간 이내에 글을 다시 쓰지 못하도록 막는 기능. 게시글 무작위 다량 등록하는 spammer 를 막기 위한 것.



# 프로젝트 개요

- 생산적이지 못하고 성공적이지 못한 결과를 만들어 내는 이유는 오직 하나, 코드를 복잡하 작성하기 때문이다. 반드시, 가장 간단한 코드로 작성되어야 하며 그렇지 않으면 실패하는 것으로 간주한다.
- 파이어베이스 데이터베이스는 NoSQL, Flat Style 구조를 가진다.
  - 그래서, Entity Relationship 을 최소화한다.

## 이슈 및 문의

- 만약, FireFlutter 를 이용하면서 어려운 점이 있으면 [Github Issues](https://github.com/thruthesky/fireflutter/issues)에 이슈를 등록해주세요.


## 버전 업그레이드 진행 상황

- [FireFlutter 0.x 버전 진행 상황](https://github.com/users/thruthesky/projects/6)

## 데이터베이스 - Firestore 와 Realtime Database

- Firestore 위주로 데이터를 저장한다.
  - 참고로, (2022년 9월 6일 환율 기준) Firestore 100만 문서 읽기에 약 520원 정도하며, Realtime Database 는 읽기/쓰기에 드는 비용이 없이 무료이다.
  - Firestore 가 문서 저장과 읽기에 비용이 발생하지만, 감당해야하는 부분이며, 최소한의 읽기(비용 지출)를 위해서 최대한의 메모리 캐시를 한다.
- Realtime Database 는 Firestore 에 비해 상대적으로 저렴하여 적극 활용 할 필요가 있다. Realtime Database 사용하는 경우는
  - 백업. Realtime Database 는 자동으로 백업을 하는 기능이 있다. 따라서 Firestore 의 데이터를 Realtime Database 에 집어 넣어 백업을 할 수 있다. 그 외 데이터 백업이 필요한 경우.
  - 단순히 데이터를 저장하고 읽는 것이 아니라, 조건을 통해서 검색(목록) 해야 하는 경우에는 Realtime Database 를 사용하지 않는다.






# 외부 패키지 목록

- 여러가지 외부 패키지를 쓰지만, 그 중에서도 몇 가지 목록을 하자면 아래와 같다.

# 기능 별 데이터 구조


- 각 기능별 데이터베이스 구조를 설명한다.
- 각 기능별로 하나의 데이터 자료는 하나의 모델 클래스로 연결된다.
  - 해당 모델 클래스는 해당 자료에 대한 속성을 가지고 또한 그 데이터 자료(1개)에 대한 CRUD 기능을 가진다.
  - 예를 들어 사용자 문서 생성, 글 생성, 코멘트 생성은 `UserModel`, `PostModel`, `CommentModel` 의 모델에서 하며, 기타 읽기, 수정, 삭제 등 자료 하나에 대한 기능을 모델이 담고 있다.
- 그 외, 각 기능별 기능은 각 Service 클래스에 기록된다.
  - 예를 들어, 검색과 같이 자료 1개에 대한 기능이 아닌 경우 Service 클래스에 기록되는데, `UserService`, `PostService`, `CommentService` 등이 있다.





## 사용자



### 사용자 문서

- `/users/<uid>` 와 같이 저장되며, 아래의 미리 지정된 필드 외에, 원하는 정보(필드)를 추가적으로 저장 할 수 있다.
- 주의 해야 할 것은 사용자 문서는 누구든지 읽을 수 있다. 따라서 개인 정보를 저장하면 안된다.
- 특히, 전화번호와 이메일주소는 `FirebaseAuth` 의 사용자 계정에 저장한다.

사용자 문서에서 미리 지정된 필드 목록)
```mermaid
erDiagram
  users {
      string name
      string firstName
      string lastName
      string photoUrl "사용자 프로필 사진. Storage 의 이미지가 아니라, 다른 서버의 이미지라도 된다."
      int birthday "YYYYMMDD 년4자리 월2자리 일2자리"
      string gender "M 또는 F"
      Timestamp createdAt "맨 처음 한번만 기록"
      Timestamp updatedAt "사용자가 프로필 변경 할 때 마다 업데이트"
  }
```






# Fireflutter 초기화

- Fireflutter 패키지를 `pubspec.yaml` 에 package 로 추가를 해도 되고, fork 하여 작업하며 수정 사항을 PR 해도 된다.
- Fireflutter 를 앱에 연동하기 위해서는 루트 위젯에 `FireFlutter.service.init(context: ...)` 을 실행한다.
  - `context` 는 각종 다이얼로그나 스낵바, Navigator.pop() 등에 사용되는 것으로 `GlobalKey<NavigatorState>()` 를 MaterialApp 에 연결한 후 그 stateContext 를 지정하거나 Get 상태 관리자를 쓴다면 `Get.context` 를 지정해도 된다.
예제)
```dart
class RootWidget extends StatelessWidget {
  const RootWidget({super.key});

  @override
  Widget build(BuildContext context) {
    FireFlutterService.instance.init(context: globalKey.currentContext!); // context 연결
    return MaterialApp(
      navigatorKey: globalKey,
    );
```

예제) Get 상태 관리자를 쓰는 경우

```dart
class RootWidget extends StatelessWidget {
  const RootWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      onReady: () {
        FireFlutterService.instance.init(context: Get.context!); // context 지정
      },
```

예제) Go_Router 를 쓰는 경우,
```dart
class RootWidget extends StatefullWidget {
  initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FireFlutterService.instance
          .init(context: router.routerDelegate.navigatorKey.currentContext!);
    });
```

# 사용자 로그인

- 사용자가 Firebase 의 Authentication 에 로그인을 하면 FireFlutterSeivce 가 `FirebaseAuth.authStateChanged()`로 감지하여 필요한 동작을 한다.
  - 플러터 앱에서 익명 로그인, 메일 주소 로그인, 전화 번호 로그인, 기타 소셜 로그인 등 상관없이 로그인만 하면 된다.
- 아래는 사용자 로그인(로그아웃)과 사용자 문서가 어떻게 업데이트가 되는지 흐름도이다.

```mermaid
flowchart TB;
Start([앱 또는 FireFlutter 시작]) --> AuthStateChange{로그인 했나?\nAuthStateChange}
AuthStateChange -->|아니오| SignInAnonymous[익명 로그인]
SignInAnonymous -->UnobserveUserDoc[사용자 모델 동기화 해제\n이벤트발생]
UnobserveUserDoc --> Continue2[계속]
UnobserveUserDoc -.-> |이벤트발생| UserDoc
UserUpdate([회원 정보 수정]) -.-> |DB UPDATE 동기화| ObserveUserDoc
AuthStateChange -->|예, 로그인 했음| ObserveUserDoc
AuthStateChange -->|예, 로그인 했음| CheckUserDoc{사용자 문서 존재하나?\n/user/$uid}
CheckUserDoc -->|아니오| CreateUserDoc[사용자 문서 생성\ncreatedAt]
ObserveUserDoc -.-> |이벤트발생| UserDoc[[UserDoc 위젯]]
CreateUserDoc -.-> |DB UPDATE 동기화| ObserveUserDoc
Logout([로그아웃]) --> AuthStateChange
CheckUserDoc -->|예, 존재함| Continue[계속]
CreateUserDoc --> Continue
ObserveUserDoc[UserService.instance.user\n사용자 모델 DB 동기화 시작\n업데이트 이벤트 발생] --> Continue
```

- 사용자가 로그인을 하지 않은 경우(또는 로그아웃을 한 경우), 자동으로 `Anonymous` 로 로그인을 한다.
- 사용자가 로그인을 하는 경우, 또는 로그인이 되어져 있는 경우, 사용자 문서를 미리 읽어 (두번 읽지 않고) 재 활용을 해 왔는데, 심플한 코드를 위해서 미리 읽지 않는다.
  - 사용자의 정보 표현이 필요한 곳에서는 `MyDoc` 위젯을 사용한다.
  - 만약, (문서 읽기 회 수를 줄이기 위해) 사용자 문서를 미리 읽어 재 활용하고자 한다면, 클라이언트 앱에서 한다.


## 전화번호 로그인

- FireFlutter 에서는 Firebase Auth 를 통한 로그인만 지원한다. 예를 들면, Anonymous, Email/password, Phone Number, Google, Apple 등의 로그인을 지원한다. 이 중에 한가지로 로그인을 하면 FireFlutter 에서 내부적으로 로그인을 감지하여 동작을 한다.

- FireFlutter 에서는 기본적으로 Phone Number 로그인을 지원하며, 관련된 Service 와 Widget 을 제공한다.
  - FireFlutter 에서 제공하는 Phone Number 로그인 서비스를 이용하면,
    - 앱을 처음 실행하면 로그인을 하지 않은 상태인데 이 때에는 자동으로 Anonymous 계정으로 로그인을 한다.
    - 그리고 사용자가 처음 사용하는 (이미 가입되어 있지 않은) 전화번호 로그인을 하면, 기존에 사용하던 Anonymous 계정과 (그 Anonymous 계정의 각종 설정을 linkWithCredential 을 통해) 합친다.
      - 만약, Anonymous 계정에서 기존에 존재하는 (이미 가입되어져 있는) 전화번호로 로그인을 하면, Anonymous 의 계정을 버린다.
    - 내부적으로 `PhoneService.instance.verifyCredential()` 에서 전화번호가 이미 가입되저 있는지
    `FunctionsApi.instance.phoneNumberExists()` 로 확인을 해서, 사용자가 로그인을 위해서 입력한 전화번호가 이미 가입되어져 있으면 `signInWithCredential()` 로 로그인을 하고 아니면, 즉 새로운 전화번호이면 이미 로그인 한 Anonymous 계정과 합치기 위해서, `linkWithCredential()` 을 사용한다.

# 사용자 정보 보여주기

- 나의 사용자 문서의 데이터를 실시간으로 보여 줄 때에는 `MyDoc` 위젯을 사용하고,
- 다른 사용자 문서를 보여 줄 때에는 `UserDoc` 위젯을 사용한다.

- `MyDoc(builder: (user) => ...)` 의 builder 함수에는 사용자가 로그인을 하지 않았으면 빈 사용자 모델을 파라메타로 전달하고, 로그인을 하였으면 그 사용자 모델을 전달한다.
  - 예제) 아래에서 `my` 가 사용자 모델이다. 로그인을 했는지 안했는지 판별하여 다른 동작을 할 수 있다.
```dart
MyDoc(
  builder: (my) =>
      my.signedIn ? Text(my.toString()) : Text('Please, sign-in'),
),
```

- `UserDoc` 위젯은 사용자 문서를 가져오기 위해 `UserService.instance.get(uid: ...)` 함수를 사용한다. 이 함수는 사용자 문서를 Firestore 에서 가져 온 후 메모리 캐시를 하므로 동일한 uid 로 여러번 호출해도 비용이 발생하지 않는다. 참고로 uid 에는 나의 uid 또는 타인의 uid 일 수 있다.

- 게시판 목록 등에서 특정 사용자 이름이 여러번 표시 될 수 있는데, 이 때 `UserService.instance.get(uid: ...)` 또는 `UserDoc` 위젯을 사용하면 된다.


- 사용자 디스플레이 이름은 사용자의 닉네임이다. 사용자의 실명 대신 닉네임을 표시하고자 할 때, displayName 을 사용하면 된다.
  - 예) `UserService.instance.displayName` 또는 `UserModel.displayName`

- 사용자 디스플레이 이름을 짧게 표시하고 한다면, shortDisplayName 을 사용 할 수 있다.
  - 예) `UserService.instance.displayName` 또는 `UserModel.shortDisplayName`




# 사진(파일) 업로드

- 사용자가 업로드하는 사진은 Storage 의 `/users/<uid>` 에 저장된다.
  - 시간이 지날 수록 사진 업로드의 수가 많아져 하나의 폴더에 모두 넣으면 관리가 어려워 진다.

- Storage 권한은 아래와 같이 지정한다.

```sh
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    match /users/{uid}/{fileName} {
      allow read;
      allow write: if uid == request.auth.uid;
    }
    
  }
}
```

- 사진은 [Resize Images](https://firebase.google.com/products/extensions/firebase-storage-resize-images) 익스텐션을 사용해서 자동 썸네일을 생성한다.
  - 썸네일은 `_320x320.webp` 로 저장되도록 해야 한다.
    - 이렇게 하기 위해서는 설정을
      - `Sizes of resized images` 에 `320x320` 크기로 지정,
      - `Deletion of original file` 에 `No` 선택,
      - `Make resized images public` 에 `Yes` 선택,
      - `Cloud Storage path for resized images` 에는 공백
      - `이미지 저장 경로(Paths that contain images you want to resize)` 를 `/users` 로 지정하고,
      - `Cache-Control header for resized images` 에 `max-age=86400`
      - `Convert image to preferred types` 에는 `webp` 만 선택
      - `Output options for selected formats` 에는 공백
      - `GIF and WEBP animated option` 에는 Yes 선택
      - `Cloud Function memory` 에는 2GB 선택
      - `Enable Events` 선택하지 않음.
  - 업로드 한 이미지는 `UploadedImage` 위젯을 통해 보여주면 된다.

- 파일 업로드 예제

```dart
FileUploadButton(
  type: 'user',
  onProgress: (p) => setState(() => this.p = p),
  onUploaded: (url) async {
    await UserService.instance.update({'photoUrl': url});
    setState(() => p = 0);
  }
  child: ...
```

## 업로드된 사진 보여주기


- 사진을 업로드 후, 보열 줄 때에는 `UploadedImage` 를 사용하면 된다. 이 위젯은 썸네일된 이미지가 있으면 보여주고 없으면 원본 이미지를 보여준다.

- `UploadedImage` 예제)

```dart
UploadedImage(
  url: user.photoUrl,
  width: size,
  height: size,
  loader: SizedBox.shrink(),
)
```


- 사용자 프로필을 보여 줄 때 `ProfilePhoto` 위젯을 쓰면 되는데, 이 위젯은 사용자 문서를 입력 받아서 그 사용자의 `photoUrl` 에 있는 프로필 사진을 보여주는 것이다. 내부적으로 `UploadedImage` 를 사용한다.
  - `GestureDector` 나 `MyDoc`, `UserDoc` 등으로 감싸서 활용 할 수 있다.

```dart
MyDoc(
  builder: (my) => ProfilePhoto(
    user: my,
    size: 100,
    emptyIcon: const Icon(
      Icons.person,
      color: Color.fromARGB(255, 111, 111, 111),
      size: 90,
    ),
  ),
),
```


# 사용자 설정

- 사용자 설정은 사용자 문서 아래에 컬렉션으로 저장된다.
  - 예) `/users/<uid>/user_settings/<settingDocumentId> { ... }`
    - `/users/<uid>/user_setttings` 컬렉션이어서 그 하위에 여러개의 문서를 생성 할 수 있다.

- 사용자의 기본 설정은 `/users/<uid>/user_settings/settings` 폴더에 저장한다.
  - 사용자 설정 관련 위젯이나 함수를 사용 할 때, `settingDocumentId` 지정을 하지 않으면, 기본적으로 `/users/<uid>/user_settings/settings` 문서에 적용이 되는데 이를 `기본 문서`라고 한다.
  - 예를 들어, 사용자 설정을 바탕으로 위젯을 표현하는 `MySettingsBuilder` 을 사용 할 때, `id` 를 지정하지 않으면, `settings` 문서의 설정을 사용한다.

## 사용자 설정을 바탕으로 위젯을 보여주는 MySettingsBuilder

- 사용자 설정을 읽어 builder 를 통해 위젯을 표현한다.
- 참고로, `MySettingsBuilder` 은 reactive 해서 설정이 변경되면 builder 가 다시 호출 되어 자식 위젯을 다시 그린다. 따라서 상태 관리나 `setState()` 를 호출 할 필요 없다.

- 예제) 스위치를 켜고 끄는 위젯인데, 상태 관리나 `setState()` 를 쓰지 않고 위젯을 다시 빌드(렌더링) 한다. 
```dart
const String commentNotification = 'notify-new-comment-under-my-posts-and-comments';
MySettingsBuilder(builder: (settings) {
  return SwitchListTile(
    title: Text('Notify new comments under my posts and comments'),
    value: settings[commentNotification] ?? false,
    onChanged: ((value) async {
      await UserService.instance.settings.update({
        commentNotification: value,
      });
    }),
  );
});
```

- 예제) Switch 위젯을 on/off 하면, 사용자 설정 문서 `post-create.qna` 이 존재하면 삭제하고, 존재하지 않으면 생성하는 예제.
  - 아래의 예제에서 `id` 를 지정하고, `settings` 값이 null 이면 설정 문서가 존재하지 않는 것이며, `setState()` 하지 않아도 builder 함수로 위젯을 새로 랜더링하는 것을 잘 익혀 다른 곳에서 재 사용 할 수 있어야 한다.
```dart
const String subDocId = 'post-create.qna';
MySettingsBuilder(
  id: subDocId,
  builder: (settings) {
    return Switch(
      value: settings != null,
      onChanged: (bool value) async {
        if (value) {
          UserService.instance.settings.doc(subDocId).update({
            'action': 'post-create',
            'category': category,
          });
        } else {
          UserService.instance.settings.doc(subDocId).delete();
        }
      },
    );
  }),
```

## 사용자 설정 관련 코드

- 사용자 설정 관련 함수(기능)는 `UserSettings` 클래스에 있으며 이 클래스 인스턴스가 `UserService.instance.settings` 멤버 변수에 저장된다.
  - 즉, `UserService.instance.settings` 를 통해서 사용하면 된다.

- `UserService.instance.settings.update()` 또는 `UserService.instance.settings.delete()` 와 같이 하면 기본 문서(`/users/<uid>/user_settings/settings`)를 업데이트 하거나 삭제한다. 즉, 문서 ID 를 지정하지 않으면 기본 문서를 사용하는 것이다.

- 만약, 기본 문서가 아닌 다른 문서를 사용하고 싶다면, `UserService.instance.settings.doc(...문서ID...)` 와 같이 원하는 문서 ID 를 지정하면 된다.
  - 예제) `UserService.instance.settings.doc('fruits').update({'a': 'apple'});`
- 사용자 설정 함수 중에서 `UserService.instance.settings.doc(...).update(...)` 는 업데이트 할 문서가 존재하지 않으면 생성을 한다.


- 예제) 아래의 예제는 여러개의 사용자 설정 문서를 읽어서, reactive 하게 re-build(랜더링)하며, 문서를 업데이트(생성)하고 삭제를 하는 예제를 보여준다.
  - 참고로, 아래의 코드는 게시판 별 푸시 알림 구독을 할지 말지 목록해서 보여 주는 것이다.
  - 아래에서 설정 파일을 어떻게 업데이트(생성)하고 삭제하는지 잘 보고, 다른 곳에서 활용 할 수 있도록 한다.
```dart
@override
Widget build(BuildContext context) {
  String id = '$type-create.${category.id}';
  return MySettingsBuilder(
    id: id,
    builder: (settings) {
      return CheckboxListTile(
        value: settings == null ? false : true,
        onChanged: ((value) async {
          if (value == true) {
            await UserService.instance.settings.doc(id).update({
              'action': '$type-create',
              'category': category.id,
            });
          } else {
            await UserService.instance.settings.doc(id).delete();
          }
        }),
        title: Text(category.title),
      );
    },
  );
}
```

- This is the sample screen of the code above.

![Push messaging settings screen](https://github.com/thruthesky/fireflutter/wiki/img/notification-settings-screen.jpg)

- This is the firestore doucment for the actions of the code above.

![Firestore messaging subscriptions](https://github.com/thruthesky/fireflutter/wiki/img/firestore-messaging-subscriptions.jpg)





- You can pass the setting's document id to `MySettingsBuilder` to oberve different settings document under `/users/<uid>/user_settings` collection.

- Use `mySettings(uid)` in `FireFlutterMixin` to get the user's settings.


### 사용자 설정 관련 코드 예

- 로그인 한 사용자의 설정을 다룰 때에는 `UserService.instance.settings` 를 사용하면 된다.
  - 예) 로그인 한 사용자 설정 문서 Document Reference 가져오기
    - `UserService.instance.settings.doc("chat.$uid")` 는 나의 설정 컬렉션에서 `chat.$uid` 에 해당하는 문서의 reference 를 가져온다. Document Reference 이므로 `.get()`, `.set()` 등의 작업을 할 수 있다.

- 다른 사용자의 설정을 다룰 때에는 `UserSettings` 클래스를 사용하면 된다. 참고로, 다른 사용자의 설정은 읽기 전용이며 쓸 수는 없다.
  - 예) 다른 사용자 설정 문서의 Document Reference 가져오기
    - `UserSettings(uid: uid, documentId: 'chat.otherUid')` 와 같이 하면 다른 사용자 컬렉션에서 `chat.otherUid` 설정 문서의 reference 를 가져온다. Document Reference 이므로 `.get()`, `.set()` 등의 작업을 할 수 있다.

- Document Reference 가 아닌 path 가져오기.
  - 단순히, DocumentReference 에 `path` 속성을 참조하면 된다.
  - 예)
    - `UserService.instance.settings.path`
    - `UserService.instance.settings.doc("chat.$uid").path`
    - `UserSettings(uid: uid, documentId: 'chat.otherUid').path`

- 참고로, `UserService.instance.settings` 는 내부적으로 `UserSettings` 클래스를 사용한다.
- `UserSettings` 클래스는 `.get()`, `.update()`, `.delete()` 세 개의 메소드를 제공하는데, 이것은 Firestore 에서 제공하는 것과 약간 다른 `UserSettings` 클래스만의 메소드이다.
  - `UserSettings.get()` 의 경우, 문서가 존재하면 문서 내용을 객체로 리턴하고, 존재하지 않으면 null 을 리턴한다. Firestore 의 `get()` 은 DocumentSnapshot 을 리턴하는 데 이 점이 서로 다르다.
  - `UserSettings.update()` 의 경우, 기존에 문서가 존재하지 않으면 생성을 한다는 점이 Firebase 의 `update()` 와 다르다.


- 예제) 아래에서 설정 문서가 존재하지 않으면 doc 에 null 값이 적용된다.
```dart
final doc = await UserSettings(uid: uid, documentId: 'chat.${UserService.instance.uid}').get();
if (doc == null) print('document does not exist');
else print('document: $doc');
```

# 게시판 카테고리

- 게시판은 `/categories`, `/posts`, 그리고 `/comments` 와 같이 세 개의 컬렉션에 게시판 관련 데이터가 저장된다.
  - 그 중에서 `/categories/<categoryId> { ... }` 에 게시판 카테고리가 저장된다.

- 카테고리에는 다음과 같은 기본 필드가 있으며 원한다면 여러분이 직접 얼마든지 추가 필드를 저장해도 된다.

```mermaid
erDiagram
  users {
      string title "카테고리 제목"
      string description "카테고리 설명"
      Timestamp createdAt "맨 처음 한번만 기록"
      string group "카테고리 그룹"
      int order "카테고리 표시 순서. 메뉴 등에서 카테고리를 표시할 순번"
      int point "최대 포인트. 사용자가 글을 쓰면 랜덤으로 포인트가 주어지는데, 그 최대 포인트"
  }
```



## CategoryService.instance.loadCategories()

- 이 함수는 Firestore 로 부터 `/categories` 컬렉션에서 카테고리 문서를 가져온다.
  - 참고로 Firestore 는 기본적으로 Offline database 로 동작하지만, `Firestore...collection...get()` 을 통해서 데이터를 가져오기 때문에 항상 서버에 접속해서 데이터를 가져온다.

- `categoryGroup` 파라메타를 통해서 특정 그룹의 카테고리만 가져올 수 있다.

## CategoryService.instance.getCategories()

- 이 함수는 `/categories` 컬렉션으로 부터 모든 카테고리 문서를 가져온다. 카테고리 그룹 별로 가져오지 않는다.
  - 다만, 이 함수는 메모리 캐시를 한다. 즉, 이 함수는 최초 한 번만 서버에 접속하여 데이터를 가져오고 그 다음 부터는 메모리에 캐시된 값을 사용하므로, 서버에 두번 접속하지 않는다. 카테고리 특성 상 한번 카테고리 설정 값이 정해지면 그 값이 잘 변하지 않기 때문에 메모리 캐시를 한다. 만약 실시간 업데이트 확인이 필요하면 직접 적절하게 코딩을 해야 한다.

- 이 함수는 `hideHiddenCategory` 옵션이 있는데, 이 값을 true 로 하면, 카테고리 속성 중에서 `order` 값이 `-1` 로 지정된 것은 가져오지 않는다. (이 것은 클라이언트에서 필터링을 한다.)

- 참고로 이 함수는 async/await 으로 동작하므로 그에 따라 적절히 사용하면 된다.

- 추천하는 사용 방법은 앱이 처음 실행(부팅)될 때, `CategoryService.instance.getCategories(hideHiddenCategory: true)` 를 통해서 모든 카테고리를 가져와 메모리에 보관을 해 놓고 필요할 때, 그 본관한 변수를 활용한다. 참고로 `Future` 방식으로 동작하므로, 최초 1회 미리 메모리에 보관해 놓고, 일반 변수로 활용하는 것이 편하다.
  - 만약, 정말, 혹시라도 `getCategories()` 가 호출되기 전에 앱에서 카테고리 정보를 먼저 사용 할 가능성이 있다면, 임시 카테고리 정보를 미리 앱 내에 설정해 놓으면 된다
- 예제) 카테고리 활용하는 방법. 아래와 같이 `categories` 변수에 임의의 카테고리를 지정해 놓고, `Config.init()` 을 앱이 부팅 할 때 호출하면 된다. 그러면 최소한 카테고리가 Firestore 로 부터 로드되지 않아 발생하는 문제를 막을 수 있다.

```dart
import 'package:fireflutter/fireflutter.dart';

class Config {
  /// 이 값은 (혹시나, 서버 쿼리에 실패할 경우 또는 서버로 부터 데이터를 가져오기 전에) 기본 적으로 메뉴로 보여 주는 값이며,
  /// 앱이 부팅하면서, 실제 category 목록을 가져와서 이곳에 덮어 쓴다.
  static Map<String, String> categories = {
    '가입인사': 'greeting',
    '질문': 'qna',
    '자유게시판': 'discussion',
    '뉴스': 'news',
    '강좌': 'tutorial',
    '개발자 스토리': 'dev-story',
  };
  static init() async {
    final snapshot = await FireFlutterService.instance.categoryCol
        .orderBy('order', descending: true)
        .get();

    categories = {};
    for (final doc in snapshot.docs) {
      final category = CategoryModel.fromSnapshot(doc);

      categories[category.title] = category.id;
    }
  }
}
```

# 게시판 글


- `/posts/<postId> { ... }` 와 같이 데이터가 저장되며, 아래의 지정된 필드 외에, 원하는 정보(필드)를 추가적으로 지정 할 수 있다.
- 글 문서에는 아래와 같이 미리 사용되는 필드들이 있는데, 여러분이 원한다면 얼마든지 추가 필드를 저장하고 활용하면 된다.
```mermaid
erDiagram
  posts {
    string uid
    string title
    string content
    Timestamp createdAt
    Timestamp updatedAt
    array_of_string files
  }
```


## 글 생성

- 글을 작성하기 위해서는 `PostModel.create()` 함수를 호출하여 글을 작성하면 된다. 
- 게시판 관련 helper 클래스 `ForumMixin` mixin 을 통해서 여러가지 기능을 간편하게 사용 할 수 있다. 또한 게시판 관련해서 기본적으로 제공되는 위젯을 통해서 간편하게 게시판 관련 기능을 작성 할 수 있다.


### 글 생성 로직 예

- 먼저, 글 목록 페이지 헤더(타이틀)에 글 생성 버튼을 추가한다.
- 글 생성 버튼을 클릭하면, 새로운 스크린을 여는 것이 아니라, 그냥 full screen dialog 를 통해서 글 작성 폼을 보여주고, 글 쓰기가 완료되면 dialog 를 닫는다.
  - 예) 글 생성 버튼을 클릭하면 `ForumMixin` 의 `onPostEdit` 함수를 호출하면 full screen dialog 가 열린다.
  - 참고로, `onPostEdit` 은 내부적으로 FireFlutter 의 `PostForm` 위젯을 사용하여 글 쓰기 폼을 보여준다.


### 글 생성 위젯 - PostForm

- 글을 생성하기 위해서는 직접 위젯을 만들어 쓰면 되는데, 기본적으로 제공하는 글 작성 위젯인 `PostForm` 에 대해서 설명을 한다.
  - 이 위젯은 `lib/src/forum/widgets/post` 폴더에 있으며 그냥 소스 코드를 열어서 복사하여 사용해도 된다.
- PostForm 은 글 쓰기에 필요한 위젯을 제공하고 있는데, 제목, 내용 입력란과 카테고리 선택, 파일 업로드 등이 있다.
- 사용자가 글 쓰기 버튼을 누르면, 이 PostForm 위젯을 새로운 스크린에 보여주어도 되고, 전체 화면 Dialog 에 보여줘도 된다.
  - 참고로, `ForumMixin::onPostEdit` 에서는 전체 화면 Dialog 를 사용해서 글 쓰기 폼을 보여주고 있다.
- 카테고리는 `category` 변수에 넣어서 전달하면 기본 선택이 되는데 추가적으로 카테고리 선택 항목을 보여주고 싶다면 `categories` 변수에 `{레이블: 카테고리, ...}` 와 같은 형태로 전달하면 된다.
- 예제)
```dart
IconButton(
  onPressed: () async {
    final post = await onPostEdit(category: 'qna', categories: {
      'QnA': 'qna',
      'Discussion': 'discussion',
    });
    print('post, $post');
  },
  icon: Icon(Icons.create, color: Theme.of(context).primaryColor),
),
```



## 글 가져오기

- 글 하나 가져오기는 `PostModel.get()` 으로 할 수 있다.

## 글 목록 가져오기

- 글 목록 가져오기는 `PostService.instance.get()` 을 통해서 할 수 있다.

- 예제)

```dart
List<PostModel> photos = await PostService.instance.get(
  category: 'news',
  limit: 5,
  hasPhoto: true,
);
```


### 글 목록을 무한 스크롤로 가져오기

- 화면에 글 목록을 표시하는 경우 `FirestoreListView` 화 함께 `postsQuery()` 를 사용하면 보다 쉽게 Firestore 로 부터 글을 가져 올 수 있다.
- 또한 글 목록을 많은 경우, 스크롤을 할 때 마다 다음 페이지에 해당하는 글 목록을 가져와야 하는데, 이 때에도 `FirestoreListView` 와 함께 `postsQuery()` 를 사용하면 된다.
- `FirestoreListView` 의 사용법에 익숙하다면, 직접 Query 를 작성해서 가져 올 수도 있겠지만 `postsQuery()` 가 조금 더 사용하기 쉽게 함수와 위젯을 추가해 놓았다.

- 아래는 StreamBuilder 를 사용해서, Firestore 로 부터 글을 가져온다.
```dart
StreamBuilder(
  stream: FirebaseFirestore.instance
      .collection('posts')
      .limit(3)
      .snapshots(),
  builder: ((context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator.adaptive();
    }
    if (snapshot.hasError) return Text(snapshot.error.toString());
    if (snapshot.hasData == false ||
        (snapshot.data?.docs ?? []).isEmpty) {
      return const Text('No posts, yet');
    }
    return Column(
      children: snapshot.data?.docs.map((doc) {
            final p = PostModel.fromSnapshot(doc);
            return ListTile(title: Text(p.displayTitle));
          }).toList() ??
          [],
    );
  }),
),
```


- 아래는 예제는 위의 예제와 비슷한 동작을 하는 코드로, FirestoreListView 와 postsQuery() 를 사용해서, Firestore 로 부터 글을 가져온다.

예제)
```dart
FirestoreListView<PostModel>(
  shrinkWrap: true,
  query: postsQuery(limit: 3),
  itemBuilder: ((context, snapshot) {
    final post = snapshot.data();
    return ListTile(
      title: Column(
        children: [
          Text('title: ${post.displayTitle}'),
        ],
      ),
      onTap: () => router.push('/view?id=${post.id}'),
    );
  }),
),
```

- 아래의 예제에는 category 와 limit 옵션을 주어서 글을 가져온다. 주의 할 점은 limit 옵션은 한번(한번의 목록)에 가져와서 보여 줄 개수로서, 반복적으로 1개씩 가져온다. 그래서 1개만 보여주는 것이 아니다.

예제)
```dart
FirestoreListView<PostModel>(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  query: postsQuery(category: 'discussion', limit: 1),
  itemBuilder: ((context, doc) {
    final post = doc.data();
    return Text(post.title);
  }),
),
```


- 글 1개만 보여주고 싶다면 아래와 같이 할 수 있다.
예제)
```dart
StreamBuilder(
  stream:
      postsQuery(category: 'discussion', limit: 1).snapshots(),
  builder: ((context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator.adaptive();
    }
    if (snapshot.hasError) {
      log(snapshot.error.toString());
      return Text(snapshot.error.toString());
    }
    if (snapshot.hasData == false || snapshot.data?.size == 0) {
      return const Text('No posts, yet');
    }

    final post = snapshot.data!.docs.first.data();
    return Text(post.title);
  }),
),
```


# 푸시 알림

- 레거시 API 를 쓰면 플러터 앱 내에서 푸시 알림을 전송 할 수 있지만, 토픽으로 메시지를 보낼 때 플랫폼 구분이 어렵다. (물론 하나의 토픽을 플랫폼별로 묶으면 android 의 click_action 과 web 의 click_action 을 따로 지정 할 수 있다.)
  - 플랫폼을 구분 할 수 있어야 Android 의 `click_action` 에는 `FLUTTER_CLICK_ACTION` 를 지정하고, web 의 `click_action` 에는 URL 을 지정 할 수 있다.
    - 참고로 Flutter 에서 `click_action` 이 없어도 onResume 등에서 올바로 동작할 수 있는지 확인이 필요하다.
  - 무엇 보다 플러터 앱에서 직접 푸시를 전송하지 않는 이유는 Firebase 에서 Legacy API 를 없애려고하는 느낌이 강하게 들었기 때문이다. 이전에는 Firebase 에서 Legacy API 가 Deprecated 되었어도 잘 사용 할 수 있었는데, 2022년 9월 즈음에 새로운 Firebase Project 를 생성하니, Legacy API 가 기본적으로 DISABLE 되어져 있었으며, 별도로 Enable 해야 했는데, 더 이상 Legacy API 를 사용하지 말라고 권하고 있다.

- 하지만, FireFlutter 0.3 에서는 토픽을 사용해서 구독을 하지 않는데, 그 이유는 로직의 복잡도가 증가하기 때문이다.
  에를 들어, 한 사용자가 핸드폰 2개를 쓰고, 여러개의 컴퓨터(데스크톱, 노트북)에서 여러개의 웹 브라우저를 쓰고 있는 경우, 토픽을 구독한 경우, 모든 핸드폰과 컴퓨터, 각 웹 브라우저 마다 동기화가 되어야 한다는 것이다. (그렇지 않으면 동작이 이상하게 된다.) 그런데 이 동기화 작업이 만만치 않다. 예를 들어 안드로이 폰에서 QnA 게시판 토픽을 subscription 했으면, 그 사용자가 사용하는 다른 폰(아이폰 등)이나 컴퓨터에서도 자동 subscription 되어야 한다. 반대로 해제하는 경우도 마찬가지이다. 만약, 사용자가 새로운 핸드폰(또는 컴퓨터)에 로그인을 한다면, 그 핸드폰(또는 컴퓨터) 또한 동기화 해야 한다. 즉 새로운 기기 마다 동기화를 해야하며, 새로운 토큰이 생성(리프레시)될 때 마다 동기화 작업이 이루어져야 한다. 문제는 이 뿐만이 아니다. 사용자가 QnA 게시판의 모든 알림(글, 코멘트) 구독하고, 개인 설정에서 내 글의 코멘트를 구독하도록 했다고 가정하면, 그 사용자가 QnA 에 글을 작성하고, 다른 사용자가 댓글을 작성하면 글 작성자에게 동일한 푸시 알림이 두 번 전송되어져 온다. 이 같은 경우, 동일한(중복된) 푸시 알림이 두 번 전송 되지 않도록 내부적으로 처리를 해야 한다. 이외에도 여러가지 필요한 작업이 있는데 만만치 많다. 사실 지금까지는 이런 방식으로 푸시 알림 로직을 개발해 왔지만, 0.3 버전 부터는 "간단한 코드"를 목표로 이런 복잡한 로직(토픽 구독)을 없애고 개별 토큰을 통해서 푸시 알림을 하도록 했다.

- 개별 토큰에 푸시 알림을 하는 것은 레거시 API 를 통해서 클라이언트에서 할 수도 있다. 하지만, 많은 토큰 문서를 클라이언트에서 서버로 부터 읽어야 하므로 클라이언트 보다는 서버에서 작업하는 것이 올바르다.
  - 참고, [푸시 알림 관련 클라우드 함수](https://github.com/thruthesky/fireflutter/blob/main/firebase/functions/src/classes/messaging.ts), [푸시 알림 유닛 테스트 코드](https://github.com/thruthesky/fireflutter/blob/main/firebase/functions/tests/messaging/send-message-with-tokens.spec.ts)

- 또한 한가지 고려해야 할 점은, 개별 토큰을 이용해서 푸시 알림을 보낼 때, 심각한 비용 증가 문제에 부딪칠 수 있다.
  - 예를 들어, QnA 게시판 구독자가 1만 명이 있고, 사용자 별 푸시 토큰이 (평균) 2개 씩이고, QnA 게시판에 하루에 글(코멘트 포함)이 100 개씩 올라 온다면, 토큰을 저장하는 문서를 2백만 번을 read 해야 한다. 이러한 푸시 알림이 다른 게시판에도 발생한다면, 그리고 시간이 지날 수록 비용은 증가 할 것이다.
  - 해결책, 토큰 저장한 문서에 read 이벤트가 많이 발생하여 비용 증가를 일으키는데 토큰을 realtime database 에 저장하면, 비용이 증가하지 않는다.
    - 기존 Firestore 문서 구조를 그대로 유지하고, 클라이언트 코드 수정없이 하려면,
      - Firestore 의 토큰 저장 문서에 클라우드 함수 write 이벤트 trigger 코딩을 해서, 토큰이 생성/수정/삭제 될 때 마다 realtime database 로 동기화시킨다. 그리고 개별 토큰을 읽어 들일 때, Firestore 가 아닌, realtime database 에서 읽어 푸시 알림을 보내면 된다.
      - @todo 이 기능은 다음 버전으로 미루도록 한다.



## 푸시 알림 관련 참고 문서

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Set up a Firebase Cloud Messaging client app on Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/client)


## 푸시 알림 설정

### Android 설정


- Android 에서 따로 설정 할 것은 없다.
- 만약, system tray 를 메시지를 클릭했는데 앱이 안열리면 main/AndroidManifest.xml 에 아래의 내용을 추가한다. 참고 [Firebase Messaging 8.0 Mirgration Guide](https://firebase.flutter.dev/docs/migration/)에는 아래의 내용 추가가 필요 없다고 하는데, ...

```xml
<intent-filter>
    <action android:name="FLUTTER_NOTIFICATION_CLICK" />
    <category android:name="android.intent.category.DEFAULT" />
</intent-filter>
```

### iOS 설정

- Firebase 연결 설정
- Xcode 의 Signing & Capabilities 에서 Push Notifications 기능 추가
- Xcode 의 Signing & Capabilities 에서 Background Modes 를 추가하고, `Background fetc` 와 `Remote notifications` 를 추가
- APNs Authentication Key 생성 후 Firebase APN 설정


## 푸시 알림 문서 구조

푸시 알림 문서는 사용자 문서 하위에 `/users/<uid>/fcm_tokens/<docId> {created_at: ..., device_type: ..., fcm_token: ... }` 와 같이 저장된다.

```mermaid
erDiagram
  Document {
    string device_type "장치의 플랫폼 이름. 참고로, FireFlutter 에서는 모두 소문자로 저장. 예) ios. 하지만 FlutterFlow 와 같이 다른 플랫폼에서는 iOS 로 저장 할 수 있으니 주의."
    string fcm_token "토큰"
    string uid "사용자 uid"
  }
```

참고로, (2022년 9월 기준) 이 구조는 FlutterFlow 에서 사용하는 구조와 비슷하다. 사실 FlutterFlow 호환을 위해서 이 구조로 작성했다.
FlutterFlow 에서는 `created_at` 이라는 필드를 따로 추가하는데, FireFlutter 에서는 이 필드를 사용하지 않는다.
또한 FlutterFlow 에서는 사용자가 계정 로그인을 해야지만 토큰을 저장할 수 있는데 반해, FireFlutter 에서는 계정 로그인을 않고, Anonymous 로그인을 해도 토큰 저장을 할 수 있다. 이것은 사용자가 계정 로그인을 하지 않아도 푸시 알림 subscription 을 할 수 있도록 기능을 만들 수 있다.
FlutterFlow 에는 없는 `uid` 를 추가했다. 이를 통해서 필요에 따라 subcollection query 를 할 수 있다.

참고로, 사용자의 모든 토큰을 하나의 문서에 저장하는 것도 생각 할 수 있는데,
얼핏 생각하면 한 사용자가 토큰을 많이 사용하는 경우, 하나의 문서에 모든 토큰을 저장하면 read 이벤트를 최소화 할 있다고 생각 할 수 있다. 하지만 사용자 대부분은 핸드폰에 앱을 설치해서 사용하는데, (웹 배포를 하면 웹으로도 같이 사용 할 수도 있지만) 어림 짐작으로 한 사용자당 토큰이 1개인 경우가 90% 이상이라 판단 된다. 그래서 문서 하나당 토큰 하나를 두는 것도 큰 문제가 없다.

참고로, `/users/<uid>/fcm_tokens/<docId>`에서 FlutterFlow 는 `<docId>` 키를 랜덤하게 생성하지만, FireFlutter 에서는 push token id 를 key 로 지정한다.


## 푸시 알림 기능 초기화

- FireFlutter 를 사용하기 위해서는 앱이 부팅 될 때 `FireFlutterService.instance.init()` 를 호출해야 한다.
- 푸시 알림 기능을 사용하기 위해서는 추가적으로 `MessagingService.instance.init()` 을 호출 해 주어야 한다.

## 푸시 알림 구독과 구현 로직

- 푸시 알림 구독은 게시판 카테고리와, 채팅 등 다양한 곳에서 사용되는데, 동작 원리를 이해해야 올바른 활용을 할 수 있다.

- 게시판의 경우 `내 글 또는 코멘트에 코멘트가 달리는 경우`, `새 글이 작성되는 경우`, `새 코멘트가 작성되는 경우` 와 같이 세 가지로 분리해서 구독을 할 수 있다.

- `내 글 또는 내 코멘트에 코멘트가 달리는 경우`는 내가 쓴 글 또는 코멘트에 누군가 답변을 달면 푸시 알림으로 빠르게 확인을 하기 위해서 구독(subscribe)를 하는데,
  - (적절한 UI 작업을 통해) 사용자가 `내 글 또는 코멘트에 답변이 달리면 푸시 알림` 버튼을 클릭하면,
  - `/users/<uid>/user_settings/settings {notify-new-comment-under-my-posts-and-comments: true}` 와 같이 설정이 된다.
  - 그러면, 클라우드 함수가 내 글 또는 내 코멘트에 답변을 달 때 마다, 푸시 나에게 알림을 보낸다.
  - 즉, 클라이언트에서는 단순하게 설정 필드에 true 또는 false 만 저장하면 나머지는 클라우드 함수가 알아서 적절한 때에 푸시 알림을 보내는 것이다.



- `새 글이 작성되는 경우` 는 특정 게시판에 새 글이 작성되면 푸시 알림을 받고 싶을 때 사용하는 것으로 게시판 카테고리 별로 구독을 할 수 있다.
  - 만약, `qna` 카테고리에 새글이 작성 될 때 마다 푸시 알림을 받고 싶다면,
  - 게시판 상단에 푸시 알림 버튼을 디자인 해 놓고 사용자가 클릭하면 구독을 하기 위해서,
    - `/users/<uid>/user_settings/{subscriptionDocumentId} {action: post-create, category: qna}` 와 같이 저장을 하면 된다.
    - 위에서 `subscriptionDocumentId` 를 `post-create.qna` 와 같이 저장하면 된다.
  - 사용자가 구독 해제를 하기 원한다면 (푸시 알림 버튼을 해제 한다면)
    - `/users/<uid>/user_settings/{subscriptionDocumentId}` 파일을 삭제하면 된다.
  - 클라우드 함수에서 위의 설정을 보고 새 글이 작성되면 사용자에게 푸시 알림을 보낸다.
  - 즉, 클라이언트에서는 단순히 설정 문서를 생성하기만 하면 푸시 알림이 동작한다. 나머지는 클라우드 함수가 알아서 푸시 알림을 보낸다.

- `새 코멘트가 작성되는 경우` 는 `새글이 작성되는 경우` 와 비슷하게 동작한다. 다만, action 이름이 `post-create` 이 아니라 `comment-create` 으로 하면 된다.


- 참고로, Firestore 의 인덱스 제한으로 필드 이름을 고유하게 설정하지 못한다. 하지만, 문서 이름은 고유하게 설정해야만 하는데, `post-create.qna` 와 같이 지정하면 된다.


- 참고로, 현재 FireFlutter 에서는 전체 사용자에게 메시지 전송을 지원하지 않는다. 대신, 파이어베이스의 `Cloud Messaging` 메뉴에서 전송을 할 수 있다.



## 푸시 알림 전송 - Push Notification 전송하기

- 푸시 전송은 Legacy API 를 지원하지 않으며, 클라우드 함수를 통해서 메시지 전송을 한다.
  - 만약 원한다면, 직접 Legacy API 를 사용하여 플러터 앱에서 푸시 알림 메세지를 전송하도록 코딩하면 된다.

- 푸시 전송은 사용자 설정 문서에 푸시 알림 구독을 하겠고 설정을 하면, 클라우드 함수에서 자동으로(적절하게) 푸시 알림을 전송하는 것과 플러터 앱 내에서 `MessagingService.instance.queue()` 함수를 호출해 직접 전송 방식이 있다.


### 게시판 글, 코멘트 관련 푸시 자동 알림

- 게시판의 글이나 코멘트는 특별하게 사용자 설정과 연동이 되어져 있다.
  - 사용자가 설정에서 on/off 를 하면 푸시 알림이 전송되거나 중단된다.


### 직접 푸시 알림 메시지 전송

- 직접 푸시 알림 메시지를 전송 할 때에는 특별히 `badge` 를 전송 할 수 있다. `badge` 는 보통 앱의 아이콘에 새로운(또는 읽지 않은) 메시지가 몇개 있는지 숫자로 표시를 해 주는 역할을 한다.
  - 흔히, 읽지 않은 문자 또는 받지 않은 전화, 또는 읽지 않은 새 카카오톡 메세지 등이 숫자로 표시되는 것을 생각하면 된다.
- App badge 예제)
![App](https://github.com/thruthesky/fireflutter/wiki/img/app-badge.jpg)



- 푸시 알림을 직접 보내기 위해서는 `MessagingService.instance.queue()` 함수를 호출하면 된다.
  - 이 함수는 Firestore 의 `/push-notifications-queue/messageId` 와 같이 `push-notifications-queue` 컬렉션 아래에 푸시 알림 정보를 담은 문서를 생성한다.
  - 그러면 Cloud function 의 background function 이 푸시 알림을 보내고 그 결과를 다시 `/push-notifications-queue/messageId` 에 저장한다.
  - 만약, 플러터앱에서 푸시 알림이 제대로 전송되었는지 확을 하려면 `queue()` 함수가 리턴하는 DocumentReference 를 observe 하면 된다.


- 참고로, 채팅 기능에서 이 방식으로 상대방에게 푸시 알림을 보내고 있다.





# 클라우드 함수

- 클라우드 함수를 최소한으로 작성하려고 하지만, 어쩔 수 없이 사용해야하는 꼭 필요한 경우가 있다.
  - 예를 들면, 사용자 전화번호가 이미 가입되어져 있는지 확인을 해서, 가입되어져 있지 않은 전화번호이면 기존 사용중인 Anonymous 계정과 합쳐야 하는데, 사용자 전화번호는 민감한 개인 정보이어서 Firebase DB 에 보관 할 수 없다. 또한 보안 규칙에서 읽기로 허용 할도 없다. 클라이언트에서 확인 할 수 있는 방법도 없으며, 이와 같은 경우에는 반드시 클라우드 함수를 써야만 한다.
  - 또 다른 예를 들면, 푸시 알림을 보낼 때, 클라이언트에서 레거시 키로 작업을 하기에는 한계가 있어 클라우드 함수에서 작업하는 것이 적당하다. [푸시 알림](#푸시-알림) 참고.

- 클라우드 함수에는 `Background functions(event triggers)`, `Call Functions from App`, `Call functions via HTTP requests` 와 같이 세 가지 방식이 있으며 이 세가지 모두 사용을 하고 있다.

- 클라우드 함수를 작업 할 때에는 필연적으로 유닛 테스트가 따라 온다. 유닛 테스트를 손 쉽게 하기 위해서 기본적인 코드를 로컬 컴퓨터에서 수정하면 바로 테스트 결과를 볼 수 있도록 작성한다. 이렇게 하기 위해서는 Firebase 의 service account 를 다운로드해서 아래와 같이 `./firebase/functions/credentials/test.service-account.ts` 로 저장을 한다.
  - 참고, 로컬 컴퓨터에서 테스트를 할 때에는 관리자 권한이 없어 service account 가 필요한 것이다. 클라우드 함수로 등록되어 실행 될 때에는 service account 없이도 (모든 권한은 아니지만) 권한이 주어져 있어 괜찮다.

```ts
export const credentials = {
  type: "service_account",
  project_id: "...",
  private_key_id: "...",
  private_key: "-----BEGIN PRIVATE KEY-----\nMI ... Ji\n-----END PRIVATE KEY-----\n",
  client_email: "...",
  client_id: "...",
  auth_uri: "...",
  token_uri: "...",
  auth_provider_x509_cert_url: "...",
  client_x509_cert_url: "...",
};
```

- 테스트가 끝나고 클라우드 함수로 실행 될 수 있도록 wrapping 한 함수를 함수를 파이어베이스에 올려서 잘 되는지 확인을 하면 된다.


## FunctionsApi

- `FunctionsApi` 는 `Call functions via HTTP requests` 를 통해서 Cloud Functions 를 사용 할 때, 도움이 되는 helper class 이다. 
- `FunctionsApi` 를 사용하기 위해서는 `init()` 를 통해서, Cloud Functions 의 서버 URL 을 기록 해 주어야 한다.
예제)
```dart
FunctionsApi.instance.init(
  serverUrl: "https://asia-northeast3-xxxxxxx.cloudfunctions.net/",
);
```

## 유닛 테스트

- 클라우드 함수 개발은 소스 코드를 변경하고 결과를 바로 확인 할 수 있는 것이 아니라 많은 시간과 번거로운 작업을 거쳐야 하기 때문에 유닛 테스트는 필수적인 개발 방법이다.
- 유닛 테스트에는 여러가지 시나리오가 있겠지만, 로컬 컴퓨터에서 테스트 소스 코드를 수정하면 실제 파이어베이스에 접속해서 (클라우드 함수 호출을 제외한) 기본 소스 코드를 테스트하는 방식을 채택했다. 이렇게 하면 로컬에서 Firebase Emulator 를 돌릴 필요는 없지만, 테스트용 파이어베이스를 하나 준비해야 한다. (실제 서비스용 파이어베이스에 테스트를 하는 것은 권장하지 않는다.)
- 테스트 명령은 아래와 같이 하면 된다. 참고로 package.json 을 살펴보고 어떻게 구성되어져 있는지 살펴본다.

예제)
```shell
$ npm run test tests/messaging/send-message-to-tokens.spec.ts
```


## 클라우드 함수 Deploy

- 클라우드 함수를 deploy 할 때에는 어느 파이어베이스에 deploy 하는지 `firebase use` 명령으로 확인을 해야 한다.




## 플러터에서 클라우드 함수 호출

- 테스트를 위한 클라우드 함수로 `success` 와 `invalidArgument` 가 있다.

```dart
try {
  final result = await callable('success');
  print("Result: ${result.data}");
} on FirebaseFunctionsException catch (error) {
  print('An error has thrown');
  print(error.code);
  print(error.details);
  print(error.message);
}
```

```dart
try {
  final result = await callable('throwInvalidArgument');
  print("Result: ${result.data}");
} on FirebaseFunctionsException catch (error) {
  print('An error has thrown');
  print(error.code);
  print(error.details);
  print(error.message);
}
```



## 푸시 알림 사운드

- Android 와 iOS 둘 다 사운드 파일을 `default_sound.wav` 로 사용한다.
  - 참고로, WAV 파일을 압축하여 작은 용량으로 사운드 파일을 추가 할 수 있다.



## 클라우드 함수 설명

### 전화번호로 가입된 사용자 UID 찾기

- `getUserUidFromPhoneNumber` 함수에 전화번호를 전달하면 사용자의 UID 값을 가져올 수 있는데, 전화 번호가 이미 가입되어져 있는지 확인 하고자 할 때 사용 할 수 있다.
- 전화번호는 `E.164` 포멧이어야 한다.
  - 형식) `+[국가코드][국번][전화번호]`
  - 예) `+821012345678`

예제)
```text
https://xxx.cloudfunctions.net/getUserUidFromPhoneNumber?phoneNumber=%2B11111111111
```

결과)
```json
{
  "uid": "jAXh1SngnafzPikQM0jpzKO3yj73"
}
```

- 전화번호가 이미 사용되고 있으면(가입되어져 있으면) 해당 사용자의 UID 를 {uid: '...'} 와 같이 리턴한다.
  - 만약, 입려된 전화번호로 가입된 사용자가 없으면 uid 에는 빈 문자열이 리턴된다.

예제)
```
https://.../getUserUidFromPhoneNumber
```
- 위 예제에는 전화번호를 전달해주지 않았다. 그래서 회원 정보를 찾지 못하며, 결과 같은 `{uid: ""}` 와 같이 빈 uid 값이 서버에서 클라이언트로 전달된다.
예제)
```
https://.../getUserUidFromPhoneNumber?phoneNumber=+11111111111
```
- 위 예제에서 문제는 기호 `+` 를 Web URL 로 전달하면, 공백으로 변경되린다. 그래서 올바른 전화번호로 인식되지 않아 회원 정보를 찾지 못한다. 그래서 `{uid: ""}` 와 같이 빈 uid 값이 서버로 부터 클라이언트로 전달된다.

예제)
```
https://.../getUserUidFromPhoneNumber?phoneNumber=%2B11111111111
```
- 위 예제와 같이 기호 `+` 를 `%2B` 로 변경해서 서버로 전달해 주면 `+` 기호를 올바로 인식한다.


### posts 글 목록

- `category` 옵션으로 카테고리 별로 글 목록을 할 수 있으며 `startAfter` 옵션과 함께 pagination 을 할 수 있다.
- `hasPhoto=Y` 옵션으로 사진이 있는 글만 가져 올 수 있으며,
- `content=N` 옵션으로 글을 가져 올 때, 내용은 제외하고 가져 올 수 있다.
- `limit=10` 옵션으로 한 번에 글을 가져오는 개 수를 지정 할 수 있다.
- 형식) `/posts?category=...&startAfter=...&hasPhoto=...&content=...&limit=...`
  - 참고로 `startAfter` 에는 Unix timestamp 를 전송해야 한다.

- 실제 예제 모음)
  - `https://asia-northeast3-xxx.net/posts`
    - 아무 옵션없이 호출 하면, 서버는 최근 글 10개 문서를 배열로 리턴
  - `https://asia-northeast3-xxx.net/posts?content=N&limit=2`
    - 서버는 글 문서 중 내용 없이, 2 개를 배열로 리턴.
  - `https://asia-northeast3-xxx.net/posts?content=N&limit=2&startAfter=1663321260`
    - 글 중에서 `1663321260` 시간 이후에 쓰여진 글 2개를 내용없이 가져온다.

- 참고로, `tests/post/posts.spec.ts` 테스트 코드를 보면 좀 더 자세히 이해를 할 수 있다.

### post 글 한 개 가져오기

- 글 문서 하나를 가져올 때 사용한다. 만약, 문서 아이디를 입력하지 않거나, 존재하지 않는 문서 아이디가 전달되면, 서버로 부터 빈 객체가 리턴된다.
  - 예) `/post?id=documentID`
  - 예) `https://asia-northeast3-xxxx.cloudfunctions.net/post?id=dxUcar1mVye2NSIGMYEW`




# Firestore 보안 규칙


## 관리자 지정
- 관리자를 지정 할 때에는 직접 Firebase Console 에서 Firestore 탭에서 `/settings/admins {<uid>: true}` 와 같이 지정을 해야 한다.

![Admin Settings](https://github.com/thruthesky/fireflutter/wiki/img/security-rules-firestore-admin.jpg)

- 위와 같이 관리자 지정된 사용자의 사용자 문서에서 `/users/<uid> {admin: true}` 를 해 주어도 되고,
  - 사용자가 앱에서 어떤 액션을 하면, 관리자 인지 확인해서, `{admin: true}` 를 프로그램적으로 지정해도 된다.
    - 예) 로그인한 사용자가 설정에서 버전 문자열을 세번 탭하면, 액션이 실행되고 관리자로 지정되어져 있으면, 자신의 사용자 문서에 `{admin: true}` 를 직접 지정하면 된다.
    - 참고로, 해커가 자신의 사용자 문서에 `{admin: true}`를 임의로 지정한다고 해도 보안 규칙에 의해서 관리자만 관리자 권한을 행사 할 수 있으므로 안전하다.

- 관리자가 지정되면, 카테고리를 생성하거나 수정 할 수 있다.


## 게시판

- 글 생성시, 카테고리를 입력해야하며, 해당 카테고리는 `/categories` 컬렉션에 문서로 존재해야 한다.

# 에러 핸들링

- FireFlutter 에서 에러를 핸들링하는 방법은 에러를 throw 하던지, 에러를 화면에 표시하던지, 아니면 에러를 화면에 표시하고, throw 하는 경우가 있다.
  - 예를 들면, `FileUploadButton` 위젯에서 사용자가 사진을 업로드 하려고 할 때, 회원 로그인을 하지 않았다면, 화면에 에러를 표시하고, 관련 에러를 throw 한다.
    - 위젯이므로 에러를 throw 해도 상위(부모) 위젯에서 catch 를 하지 못한다. 즉, 최상위 에러 핸들러에서 핸들링 해야하는 것이다. 예) `FlutterError.onError`
    - 만약, `FileUploadButton` 에서 회원 로그인하지 않아서 발생하는 에러를 화면에 표시하지 않도록 하고, 별도로 커스터마이징하고 싶다면 아래와 같이 하면 된다.
```dart
FireFlutterService.instance.init(
  context: router.routerDelegate.navigatorKey.currentContext!,
  error: (message) {
    /// 이렇게 FireFlutter 에서 화면에 표시되는 모든 에러 메시지 전체를 핸들링

    /// 필요에 따라 커스터마이징
    if (message == ERROR_SIGN_IN_FIRST_FOR_FILE_UPLOAD) {
      return ffAlert('앗', '사진 업로드를 위해서는 먼저 로그인을 해 주세요.');
    } else {
      return ffAlert('ERROR', message);
    }
  },
);
```


# Firestore 인덱싱

- (인덱싱이 필요한데) 인덱싱이 되지 않은 쿼리를 할 때, Firestore 는 인덱스를 생성할 수 있는 link 와 함께 인덱싱을 하라는 에러를 낸다. 그 link 를 클릭해서 인덱스를 생성하면 된다.
  - 클라이언트 앱 개발을 할 때, 개발자 콘솔에 에러 메시지가 표시되어 인덱싱이 되지 않은 경우, 보다 쉽게 인덱스를 생성 할 수 있는데, Cloud Functions 에서 쿼리를 할 때, 인덱스가 생성되지 않았다는 에러가 발생하면, GCP 의 로그에서 확인을 해야 하기 때문에, 인덱스가 생성되지 않아서 발생하는 에러를 발견하기 어렵다. 따라서, 클라우드 함수의 기능이 올바로 동작하지 않는 경우, GCP 로그를 확인해서 인덱스 문제가 발생하는지 살펴봐야 한다.

- 설치 항목에 나오는데로 준비된 Firestore Indexes 를 설정하면 된다.





# 포인트와 레벨

- FireFlutter 는 회원이 글을 쓸 때, 랜덤으로 포인트가 증가한다. 이것을 `포인트 이벤트`라고 부른다. 만약 포인트 이벤트 기능이 필요 없다면 그냥 무시하고 사용하지 않아도 된다.
- 사용자가 글이나 코멘트를 생성 할 때, 지정된 포인트 내에서 랜덤 값의 포인트를 생성하여 포인트 문서(`/users/<uid>/user_meta/point`)에 저장한다.
  - 포인트 문서는 보안 규칙에서 읽기 전용으로 설정되어야 한다.
  - 포인트 이벤트가 발생하면, 랜덤으로 획득한 포인트를 포인트 문서에 누적 기록하고,
  - 포인트 이벤트 발생 기록을 `/user/<uid>/point_history/<pointHistoryId> {...}` 에 보관한다.
    - 원한다면, 메뉴를 만들어 포인트 기록을 보여 줄 수 있다.
- 포인트는 보안으로 인해 오직 클라우드 함수에 의해서 적용이되는데 글 또는 코멘트가 쓰여지면 자동으로 동작을 한다.
- 사용자 포인트는 - `DocumentBuilder()` 를 통해서 reative 하게 값을 화면에 표시 할 수 있다.
  - `FireFlutterService.instance.level` 을 통해서 사용자 레벨을 확인 할 수 있다.

예제)
```dart
DocumentBuilder(
  path: UserService.instance.pointDoc.path,
  builder: (data) {
    final point = data?['point'] ?? 0;
    return Text(
      'Lv. ${FireFlutterService.instance.getLevel(point)}, Point. $point',
      style: small,
    );
  },
),
```


- 참고로, 글과 코멘트를 작성 할 때 마다 포인트가 증가하지 않고, 특정 시간이 지나야 한다. 또한 글과 코멘트를 작성 할 때 일정한 값의 포인트가 증가하는 것이 아니다. 아래의 포인트 설정 항목을 참고한다.

- 참고로, 포인트 이벤트가 발생하면 해당 글 또는 코멘트의 문서의 `point` 필드에 획득한 포인트가 기록된다. 그 포인트를 화면에 보여 줄 수 있다.



## 포인트 설정

- `<project>/firebase/functions/src/config.ts` 에 포인트에 대한 기본 설정이 있는데, 원한다면 이 값을 변경하여 cloud functions 에 deploy 하면 된다.
  - `maximumCommentCreationPoint` 는 코멘트를 작성 할 때, 최대로 증가하는 포인트 값이다.
  - `pointEvent[EventName.postCreate].within` 은 마지막으로 글을 쓴 후, 지정된 시간(초 단위)내에 다시 글을 쓰면 포인트가 증가하지 않는다.
  - `pointEvent[EventName.commentCreate].within` 은 마지막으로 코멘트를 쓴 후, 지정된 시간(초 단위)내에 다시 코멘트를 쓰면 포인트가 증가하지 않는다.
  - `within` 값으로 너무 빨리 글을 쓰는 경우, 코멘트를 주지 않을 수 있다. 포인트를 획득하기 위해 쓸데없는 글을 등록하는 경우를 방지하기 위한 것이다.
    - 만약, 글과 코멘트를 쓸 때 마다 포인트를 증가하고 싶다면, `within` 값을 0 또는 1 과 같이 아주 적은 값으로 지정 하면 된다.

- 글 쓰기의 경우, 관리자가 각 카테고리 설정에서 일일히 최대 포인트의 값을 설정해야 한다. 기본 값은 0 또는 빈 값이며, 이 때에는 포인트 이벤트가 발생해도 포인트가 증가하지 않는다.
  - 예를 들어, qna 카테고리 설정에서 point 를 100 으로 지정했다면, 포인트 이벤트가 발생 할 때, 최소 1에서 최대 100 의 값이 랜덤으로 생성되어 사용자 포인트 문서에 추가되고 포인트 기록이 남는다.
  - 때로는 사용자들이 포인트 획득을 위해서 악의적으로 의미없는 글을 쓰는 경우가 있는데, 포인트 설정을 적절히 조정 할 수 있다.


## Common Fitfalls

- 관리자가 카테고리 설정에서 포인트 설정을 하지 않고, 포인트가 증가되지 않는다고 문의를 하는 경우가 종종있다.
  - 코멘트의 경우, 포인트 설정을 하지 않아도 자동으로 포인트가 증가한다. 코멘트를 작성 시 증가하는 최대 포인트를 각 카테고리 별로 설정을 하게 하는 것은 아직 고려하고 있지 않다.


# 위젯

- FireFlutter 에서 제공하는 기본 위젯을 설명한다.


## DocumentBuilder

- Firestore 문서를 observe 하여 그 문서가 업데이트되면 reative 하게 위젯을 빌드해서 보여준다.


## Admin

- 로그인한 관리자이면 위젯을 빌드해서 보여준다.



## RecentPostCard - 사진이 있는 최근 글 카드로 보여주기

- 가장 최근에 작성된 글 중에서 사진이 있는 글을 가져와 Card 형식으로 보여준다.
  - 특정 카테고리를 지정할 수 있으며, onTap 이벤트를 통해서 사용자가 탭을 하면, 원하는 동작을 할 수 있다.
  - `RecentPostCard` 위젯의 소스 코드를 복사해서 원하는데로 커스터마이징을 해도 좋다.

- 아래의 예제는 카드를 탭하면 글 읽기 스크린으로 이동한다.

예제)
```dart
RecentPostCard(
  category: 'discussion',
  onTap: (post) => router.push('${PostViewScreen.routeName}?id=${post.id}'),
),
```

결과)

![Recent Post Card](https://github.com/thruthesky/fireflutter/wiki/img/recent-post-card.jpg)



# 실험 코드

- 개발을 진행 함에 있어서 데이터 구조 변경이 필요한 경우가 있다. 그와 같은 경우 기존의 데이터 포맷을 새로운 데이터 포맷에 맞게 포팅을 해야하는데, 그러한 포팅 작업(소스 코드 작업)을 `<project>/firebase/lab` 폴더에서 하면 된다.
- 실행은
  - `% npm run lab porting/porting-user-data.ts` 와 같이 실행을 하면 된다.





# 문제 해결

## 인덱스 문제

- Cloud functions 이 제대로 동작하지 않으면, 로그를 살펴봐야하는데, 만약 GCP 콘솔에서 `FAILED_PRECONDITION: The query requires ... index ...` 와 같은 에러 메시지를 보면 인덱싱이 안된 경우이다. 해당 link 로 접속해서 인덱싱을 생성하면 된다.


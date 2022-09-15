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
  - [글](#글)
- [Fireflutter 초기화](#fireflutter-초기화)
- [사용자 로그인](#사용자-로그인)
  - [전화번호 로그인](#전화번호-로그인)
- [사용자 정보 보여주기](#사용자-정보-보여주기)
- [사진(파일) 업로드](#사진파일-업로드)
  - [업로드된 사진 보여주기](#업로드된-사진-보여주기)
- [사용자 설정](#사용자-설정)
  - [사용자 설정을 바탕으로 위젯을 보여주는 MySettingsDoc](#사용자-설정을-바탕으로-위젯을-보여주는-mysettingsdoc)
  - [사용자 설정 관련 함수](#사용자-설정-관련-함수)
- [글](#글-1)
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
  - [푸시 알림 코딩](#푸시-알림-코딩)
  - [푸시 알림 구독](#푸시-알림-구독)
- [클라우드 함수](#클라우드-함수)
  - [FunctionsApi](#functionsapi)
  - [유닛 테스트](#유닛-테스트)
  - [클라우드 함수 Deploy](#클라우드-함수-deploy)
  - [플러터에서 클라우드 함수 호출](#플러터에서-클라우드-함수-호출)
  - [푸시 알림 사운드](#푸시-알림-사운드)
  - [클라우드 함수 설명](#클라우드-함수-설명)
    - [전화번호로 가입된 사용자 UID 찾기](#전화번호로-가입된-사용자-uid-찾기)
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
- [실험 코드](#실험-코드)
- [문제 해결](#문제-해결)
  - [인덱스 문제](#인덱스-문제)


# 해야 할 것

- 보안 규칙 설명
- Cloud Functions 설명

- `ForumMixin` 을 `ForumService` 로 변경한다. 통일된 코딩 방식이 필요하다.


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
  - 다음 버전에서 업데이트 할 때, Cloud functions 를 통해서 해결한다.
    - `/users/<uid>/fcm_tokens/<tokenId>` 를 `onWrite` 이벤트 trigger 를 통해서 `all`,`andriod`,`ios`,`web` 등의 토픽으로 자동 subscription 한다.

- (다음버전) 푸시 알림은 글 관련 모델에서 동작한다. 플러터플로에서 활용 할 수 있도록 위젯을 별도로 만들거나, 라이브러리를 만들어 본다.

- (다음버전) 다음 글 쓰기 대기 시간. 예를 들어, buyandsell 게시판에 글을 한번 쓰면 60 분 또는 24 시간 이내에 글을 다시 쓰지 못하도록 막는 기능.

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

- 미리 지정된 필드 목록
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


## 글

- `/posts/<postId>` 와 같이 데이터가 저장되며, 아래의 지정된 필드 외에, 원하는 정보(필드)를 추가적으로 지정 할 수 있다.
- 미리 지정된 필드 목록
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
  - 예를 들어, `MySettingsDoc` 을 사용 할 때, `id` 를 지정하지 않으면, `settings` 문서의 설정을 사용한다.

## 사용자 설정을 바탕으로 위젯을 보여주는 MySettingsDoc

- 사용자 설정을 읽어 builder 를 통해 위젯을 표현한다.
- 참고로, `MySettingsDoc` 은 reactive 해서 설정이 변경되면 builder 가 다시 호출 되어 자식 위젯을 다시 그린다. 따라서 상태 관리나 `setState()` 를 호출 할 필요 없다.

* 예제) 스위치를 켜고 끄는 위젯인데, 상태 관리나 `setState()` 를 쓰지 않고 위젯을 다시 빌드(렌더링) 한다. 
```dart
MySettingsDoc(builder: (settings) {
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

## 사용자 설정 관련 함수

- 사용자 설정 관련 함수(기능)는 `UserSettings` 클래스에 있으며 이 클래스 인스턴스가 `UserService.instance.settings` 멤버 변수에 저장된다.
  - 즉, `UserService.instance.settings` 를 통해서 사용하면 된다.

- `UserService.instance.settings.update()` 또는 `UserService.instance.settings.delete()` 와 같이 하면 기본 문서(`/users/<uid>/user_settings/settings`)를 업데이트 하거나 삭제한다. 즉, 문서 ID 를 지정하지 않으면 기본 문서를 사용하는 것이다.

- 만약, 기본 문서가 아닌 다른 문서를 사용하고 싶다면, `UserService.instance.settings.doc(...문서ID...)` 와 같이 원하는 문서 ID 를 지정하면 된다.
  - 예제) `UserService.instance.settings.doc('fruits').update({'a': 'apple'});`
- 사용자 설정 함수 중에서 `UserService.instance.settings.doc(...).update(...)` 는 업데이트 할 문서가 존재하지 않으면 생성을 한다.


- 예제) 아래의 예제는 여러개의 사용자 설정 문서를 읽어서, reactive 하게 re-build(랜더링)하며, 문서를 업데이트(생성)하고 삭제를 하는 예제를 보여준다.
  - 참고로, 아래의 코드는 게시판 별 푸시 알림 구독을 할지 말지 목록해서 보여 주는 것이다.
```dart
@override
Widget build(BuildContext context) {
  String id = '$type-create.${category.id}';
  return MySettingsDoc(
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





- You can pass the setting's document id to `MySettingsDoc` to oberve different settings document under `/users/<uid>/user_settings` collection.

- Use `mySettings(uid)` in `FireFlutterMixin` to get the user's settings.




# 글

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


- 아래는 FirestoreListView 와 postsQuery() 를 사용해서, Firestore 로 부터 글을 가져온다.
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


# 푸시 알림

- 레거시 API 를 쓰면 플러터 앱 내에서 푸시 알림을 전송 할 수 있지만, 토픽으로 메시지를 보낼 때 플랫폼 구분이 어렵다. (물론 하나의 토픽을 플랫폼별로 묶으면 android 의 click_action 과 web 의 click_action 을 따로 지정 할 수 있다.)
  - 플랫폼을 구분 할 수 있어야 Android 의 `click_action` 에는 `FLUTTER_CLICK_ACTION` 를 지정하고, web 의 `click_action` 에는 URL 을 지정 할 수 있다.
    - 참고로 Flutter 에서 `click_action` 이 없어도 onResume 등에서 올바로 동작할 수 있는지 확인이 필요하다.
  - 무엇 보다 Firebase 에서 Legacy API 를 없애려고하는 느낌이 강하게 든다. 이전에는 Firebase 에서 Legacy API 가 Deprecated 되었어도 잘 사용 할 수 있었는데, 2022년 9월에 새로운 Firebase Project 를 생성하니, Legacy API 가 기본적으로 DISABLE 되어져 있었다.

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


## 푸시 알림 코딩

- 푸시 알림을 이용하기 위해서는 `FireFlutterService.instance.init()` 외에 추가적으로 `MessagingService.instance.init()` 을 추가 해 주어야 한다.

## 푸시 알림 구독

- [영어]() 참고.




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




# Firestore 보안 규칙


## 관리자 지정
- 관리자를 지정 할 때에는 직접 Firebase Console 에서 Firestore 탭에서 `/settings/admins {<uid>: true}` 와 같이 지정을 해야 한다.

![Admin Settings](https://github.com/thruthesky/fireflutter/wiki/img/security-rules-firestore-admin.jpg)

- 위와 같이 관리자 지정된 사용자의 사용자 문서에서 `/users/<uid> {admin: true}` 를 해 주어도 되고,
  - 프로그램적으로 적절한 액션을 하면, 프로그램적으로 지정해도 된다.
    - 예) 로그인한 사용자가 설정에서 버전 문자열을 세번 탭하면, 액션이 실행되고 관리자로 지정되어져 있으면, 자신의 사용자 문서에 `{admin: true}` 를 직접 지정하면 된다.
    - 참고로, 해커가 `{admin: true}`를 임의로 지정한다고 해도 보안 규칙에 의해서 관리자만 관리자 권한을 행사 할 수 있으므로 안전하다.

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




# 실험 코드

- 개발을 진행 함에 있어서 데이터 구조 변경이 필요한 경우가 있다. 그와 같은 경우 기존의 데이터 포맷을 새로운 데이터 포맷에 맞게 포팅을 해야하는데, 그러한 포팅 작업(소스 코드 작업)을 `<project>/firebase/lab` 폴더에서 하면 된다.
- 실행은
  - `% npm run lab porting/porting-user-data.ts` 와 같이 실행을 하면 된다.





# 문제 해결

## 인덱스 문제

- Cloud functions 이 제대로 동작하지 않으면, 로그를 살펴봐야하는데, 만약 GCP 콘솔에서 `FAILED_PRECONDITION: The query requires ... index ...` 와 같은 에러 메시지를 보면 인덱싱이 안된 경우이다. 해당 link 로 접속해서 인덱싱을 생성하면 된다.


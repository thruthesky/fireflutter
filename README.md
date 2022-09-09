# FireFlutter v0.3

[English version](README.en.md)


- [FireFlutter v0.3](#fireflutter-v03)
- [해야 할 것](#해야-할-것)
- [프로젝트 개요](#프로젝트-개요)
  - [데이터베이스](#데이터베이스)
- [외부 패키지 목록](#외부-패키지-목록)
- [기능 별 데이터 구조](#기능-별-데이터-구조)
  - [사용자](#사용자)
    - [사용자 문서](#사용자-문서)
  - [글](#글)
- [Fireflutter 초기화](#fireflutter-초기화)
- [사용자 로그인](#사용자-로그인)
- [사용자 정보 보여주기](#사용자-정보-보여주기)
- [사진(파일) 업로드](#사진파일-업로드)
  - [업로드된 사진 보여주기](#업로드된-사진-보여주기)
- [글](#글-1)
  - [글 생성](#글-생성)
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
- [클라우드 함수](#클라우드-함수)
  - [유닛 테스트](#유닛-테스트)
  - [클라우드 함수 Deploy](#클라우드-함수-deploy)
  - [플러터에서 클라우드 함수 호출](#플러터에서-클라우드-함수-호출)
  - [푸시 알림 사운드](#푸시-알림-사운드)


# 해야 할 것

- 플러터코리아 앱을 https://flutterkorea.co.kr 로 연결하고, 최대한 빠르게 배포한다.
  - 그리고, FlutterFlow 로 연결해서, 강좌 앱을 만들도록 한다.

- 푸시 알림을 본 문서의 [푸시 알림](#푸시-알림)에 나오는데로 수정한다.
  - 토픽 구독 없이, 토큰으로 모든 subscription 로직 작성.
  - 토큰 문서 구조를 FireFlutter 지원하도록 `/users/<uid>/fcm_tokens` 로 변경.
- 글 쓰기 등 권한이 필요한 경우, `FireFlutterService.instance.init(permission: (Permission p)) {}` 와 같이 해서, 프로필이 완료되었는지, 레벨이 되는지 등을 검사해서, 권한을 부여 할 수 있도록 한다.


# 프로젝트 개요

- 생산적이지 못하고 성공적이지 못한 결과를 만들어 내는 이유는 오직 하나, 코드를 복잡하 작성하기 때문이다. 반드시, 가장 간단한 코드로 작성되어야 하며 그렇지 않으면 실패하는 것으로 간주한다.
- 파이어베이스 데이터베이스는 NoSQL, Flat Style 구조를 가진다.
  - 그래서, Entity Relationship 을 최소화한다.


## 데이터베이스

- Firestore 위주로 데이터를 저장하며, Realtime Database 는 백업 용도로 쓴다.
  - 참고로, (2022년 9월 6일 환율 기준) Firestore 100만 문서 읽기에 약 520원 정도하며, Realtime Database 는 읽기/쓰기에 드는 비용이 없이 무료이다.
- Realtime Database 는 Firestore 에 비해 상대적으로 저렴하여 적극 활용 할 필요가 있다. Realtime Database 사용하는 경우는
  - 백업. Realtime Database 는 자동으로 백업을 하는 기능이 있다. 따라서 Firestore 의 데이터를 Realtime Database 에 집어 넣어 백업을 할 수 있다. 그 외 데이터 백업이 필요한 경우.
  - 데이터를 저장만 하는 것이 아니라, 읽어야 하는 경우에는 Realtime Database 를 사용하지 않는다.
- Firestore 가 문서 저장과 읽기에 비용이 발생하지만, 감당해야하는 부분이며, 최소한의 읽기(비용 지출)를 위해서 최대한의 메모리 캐시를 한다.




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

# 글

## 글 생성

- 글을 작성하기 위해서는 `PostModel.create()` 함수를 호출하면 된다.
- `ForumMixin` mixin 의 `onPostEdit`

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

- 화면에 표시해야 할 글 목록을 많은 경우, 스크롤을 할 때 마다 다음 페이지에 해당하는 글 목록을 가져와야 하는데, 가장 표준적이고 쉬운 방법인 `FirestoreListView`를 사용 하였다.
- `FirestoreListView` 의 사용법에 익숙하다면, 직접 Query 를 작성해서 가져 올 수도 있겠지만 조금 더 사용하기 쉽게 함수와 위젯을 추가해 놓았다.

```dart
FirestoreListView<PostModel>(
  query: posts(),
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
    - 참고로 Flutter 에서 `click_action` 이 없어도 올바로 동작할 수 있는지 확인이 필요하다.
- 무엇 보다 Firebase 에서 Legacy API 를 없애려고하는 느낌이 강하게 든다. 이전에는 Firebase 에서 Legacy API 가 Deprecated 되었어도 잘 사용 할 수 있었는데, 2022년 9월에 새로운 Firebase Project 를 생성하니, Legacy API 가 기본적으로 DISABLE 되어져 있었다.
- 이러한 이유로 푸시 알림을 (플러터 앱에서 보낼 수 있음에도 불구하고) 전송 할 때, 클라우드 함수를 통해 새로운 API(v1) 사용한다.
- 참고, [푸시 알림 관련 클라우드 함수](https://github.com/thruthesky/fireflutter/blob/main/firebase/functions/src/classes/messaging.ts), [푸시 알림 유닛 테스트 코드](https://github.com/thruthesky/fireflutter/blob/main/firebase/functions/tests/messaging/send-message-with-tokens.spec.ts)
- 또한, 클라우 함수를 통해서 푸시 알림을 할 때에 가능한 topic 을 사용하지 않고, 개별 토큰에 메시지를 보낸다.
  - Topic 을 사용하지 않는 이유는 한 사용자가 핸드폰 2개를 쓰고, 여러개의 컴퓨터(데스크톱, 노트북)에서 여러개의 웹 브라우저를 쓰는 경우 동기화를 시켜야하는데 이 작업이 만만치 않다. 예를 들어 안드로이 폰에서 QnA 게시판 토픽을 subscription 했으면, 그 사용자가 사용하는 다른 폰(아이폰 등)이나 컴퓨터에서도 자동 subscription 되어야 한다. 반대로 해제하는 경우도 마찬가지이다. 문제는 이 뿐만이 아니다. 사용자가 QnA 게시판의 모든 알림(글, 코멘트) 구독하고 설정에서 내 글의 코멘트를 구독하도록 했다면, 그 사용자가 QnA 에 글을 작성하고, 댓글이 있으면 동일한 푸시 알림이 두 번 전송되어져 온다. 이 때, 동일한 푸시 알림이 두 번 전송 되지 않도록 내부적으로 처리를 해야 한다. 이외에도 여러가지 필요한 작업이 있는데 만만치 많다. 사실 지금까지는 이런 방식으로 푸시 알림 관련 작업을 해 왔지만, 0.3 버전 부터는 개별 토큰에 직접 메시지를 보내도록 변경을 했다.
- 예를 들어, 여러 사용자가 QnA 구독하는 경우, 해당 QnA 구독을 각 사용자 설정에 기록을 하고, QnA 구독자에게 푸시 알림을 보내야하는 경우, QnA 구독자(들)의 모든 토큰을 가져와서, 클라우드 함수에서 메시지를 보내면 된다.
  - 이렇게 하면, 복잡한 토픽 subscription 로직을 작성할 필요 없다.
  - 또한 토큰을 저장한 문서를 많이 읽을 필요가 있고, 또 많은 네트워크 접속이 필요할 수 있으므로 클라이언트 앱 보다는 서버 측에서 이런 작업을 하는 것이 올바르다.



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


# 클라우드 함수

- 클라우드 함수를 최소한으로 작성하려고 하지만, 꼭 필요한 경우가 있다.
  - 예를 들면, 푸시 알림을 보낼 때, 레거시 키로 작업을 하기에는 한계가 있다. [푸시 알림](#푸시-알림) 참고.

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



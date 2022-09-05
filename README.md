# FireFlutter v0.3

[English version](README.en.md)


- [FireFlutter v0.3](#fireflutter-v03)
- [개요](#개요)
- [해야 할 것](#해야-할-것)
- [외부 패키지 목록](#외부-패키지-목록)
- [기능 별 데이터 구조](#기능-별-데이터-구조)
  - [사용자](#사용자)
    - [사용자 문서](#사용자-문서)
  - [글](#글)
- [Fireflutter 연동](#fireflutter-연동)
- [사용자 로그인](#사용자-로그인)
- [사용자 정보 보여주기](#사용자-정보-보여주기)
- [사진(파일) 업로드](#사진파일-업로드)
  - [업로드된 사진 보여주기](#업로드된-사진-보여주기)
- [글](#글-1)
  - [글 생성](#글-생성)
  - [글 가져오기](#글-가져오기)
  - [글 목록 가져오기](#글-목록-가져오기)
- [푸시 알림](#푸시-알림)
  - [푸시 알림 관련 참고 문서가](#푸시-알림-관련-참고-문서가)

# 개요

- 생산적이지 못하고 성공적이지 못한 결과를 만들어 내는 이유는 오직 하나, 코드를 복잡하 작성하기 때문이다. 반드시, 가장 간단한 코드로 작성되어야 하며 그렇지 않으면 실패하는 것으로 간주한다.
- 파이어베이스 데이터베이스는 NoSQL, Flat Style 구조를 가진다.
  - 그래서, Entity Relationship 을 최소화한다.

# 해야 할 것

- 글 쓰기 등 권한이 필요한 경우, `FireFlutter.instance.init(permission: (Permission p)) {}` 와 같이 해서, 프로필이 완료되었는지, 레벨이 되는지 등을 검사해서, 권한을 부여 할 수 있도록 한다.

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





# Fireflutter 연동

- Fireflutter 패키지를 `pubspec.yaml` 에 package 로 추가를 해도 되고, fork 하여 작업하며 수정 사항을 PR 해도 된다.
- Fireflutter 를 앱에 연동하기 위해서는 루트 위젯에 `FireFlutter.service.init(context: ...)` 을 실행한다.
  - `context` 는 각종 다이얼로그나 스낵바, Navigator.pop() 등에 사용되는 것으로 `GlobalKey<NavigatorState>()` 를 MaterialApp 에 연결한 후 그 stateContext 를 지정하거나 Get 상태 관리자를 쓴다면 `Get.context` 를 지정해도 된다.
예제)
```dart
class RootWidget extends StatelessWidget {
  const RootWidget({super.key});

  @override
  Widget build(BuildContext context) {
    FireFlutter.instance.init(context: globalKey.currentContext!); // context 연결
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
        FireFlutter.instance.init(context: Get.context!); // context 지정
      },
```

# 사용자 로그인

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

- `MyDoc` 은 장치를 소유한 사용자의 정보를 보여준다. 로그인을 하지 않았으면 빈 사용자 모델을 파라메타로 전달하고, 로그인을 하였으면 그 사용자 모델을 전달한다.

- 예제) `my` 가 사용자 모델이다. 로그인을 했는지 안했는지 판별하여 다른 동작을 할 수 있다.

```dart
MyDoc(
  builder: (my) =>
      my.signedIn ? Text(my.toString()) : Text('Please, sign-in'),
),
```

# 사진(파일) 업로드

- 사용자가 업로드하는 사진은 Storage 의 `/users/<uid>` 에 저장된다.
  - 시간이 지날 수록 사진 업로드의 수가 많아져 하나의 폴더에 모두 넣으면 관리가 어려워 진다.

- Storage 권한은 아래와 같이 지정한다.

```text
match /users/{uid} {
  allow read: if true;
  allow write: if uid == request.auth.uid;
}
```

- 사진은 [Resize Images](https://firebase.google.com/products/extensions/firebase-storage-resize-images) 익스텐션을 사용해서 자동 썸네일을 생성한다.
  - 썸네일은 `_320x320.webp` 로 저장되도록 해야 한다.
    - 이렇게 하기 위해서는 설정을 `이미지 저장 경로` 를 `/users` 로 지정하고, 썸네일을 `320x320` 크기로 `webp` 형태로 저장하면 된다.
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



# 푸시 알림

## 푸시 알림 관련 참고 문서가

- [HTTP guidelines](https://cloud.google.com/apis/docs/http)
- [Firebase Cloud Messaging API](https://firebase.google.com/docs/reference/fcm/rest)
- [Firebase Cloud Messaging HTTP protocol](https://firebase.google.com/docs/cloud-messaging/http-server-ref)
# FireFlutter v0.3

[English version](README.en.md)



# 개요

- 수 많은 날을 코딩하면서 생산적이지 못하고 성공적이지 못한 결과를 만들어 낸 이유는 오직 하나, 복잡한 코드를 작성했기 때문이다.
  - 본 프로젝트는 반드시, 가장 간단한 코드로 작성되어야 하며 그렇지 않으면 실패한 것으로 간주한다.
- 파이어베이스 데이터베이스는 NoSQL, Flat Style 구조를 가진다.
  - 그래서, Entity Relationship 을 최소화한다.

# 데이터베이스




```mermaid
erDiagram
    users {
        string name
        string firstName
        string lastName
        int birthday "YYYYMMDD 년4자리 월2자리 일2자리"
        string gender "M 또는 F"
    }
```




# 코딩 가이드


- `User` 클래스는 사용자 정보를 관리한다.
- `Post` 클래스는 글 정보를 관리한다.
- `Comment` 클래스는 코멘트 정보를 관리한다.

# Fireflutter 연동

- Fireflutter 를 앱에 연동하기 위해서는 루트 위젯에 `FireFlutter.service.init()` 을 실행한다.

예제)
```dart
class WonderfulKorea extends StatelessWidget {
  const WonderfulKorea({super.key});

  @override
  Widget build(BuildContext context) {
    FireFlutter.instance.init();
    // ...
```

# 사용자 로그인

```mermaid
flowchart TB;
Start([FireFlutter 시작 또는 앱 시작]) --> AuthStateChange{로그인 했나?\nAuthStateChange}
AuthStateChange -->|예, 사용자 로그인| CheckUserDoc{사용자 문서 존재\n/user/$uid}
CheckUserDoc -->|예, 존재함| Continue
CheckUserDoc -->|아니오| CreateUserDoc[사용자 문서 생성\ncreatedAt]
CreateUserDoc --> Continue
AuthStateChange -->|아니오| SignInAnonymous[익명 로그인]
SignInAnonymous --> Continue[계속]
Logout([로그아웃]) --> AuthStateChange
```

- 사용자가 로그인을 하지 않은 경우(또는 로그아웃을 한 경우), 자동으로 `Anonymous` 로 로그인을 한다.
- 사용자가 로그인을 하는 경우, 또는 로그인이 되어져 있는 경우, 사용자 문서를 미리 읽어 (두번 읽지 않고) 재 활용을 해 왔는데, 심플한 코드를 위해서 미리 읽지 않는다.
  - 사용자의 정보 표현이 필요한 곳에서는 `MyDoc` 위젯을 사용한다.
  - 만약, (문서 읽기 회 수를 줄이기 위해) 사용자 문서를 미리 읽어 재 활용하고자 한다면, 클라이언트 앱에서 한다.

# 사진(파일) 업로드와 보여주기

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
  - 업로드 한 이미지는 `UploadedImage` 위젯을 통해 보여주면 되는데, 이 위젯은 썸네일된 이미지가 있으면 보여주고 없으면 원본 이미지를 보여준다.



* 파일 업로드 예제
```
```

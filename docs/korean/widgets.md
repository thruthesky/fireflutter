# 위젯

fireship 에서 제공하는 기본 위젯에 대한 설명을 한다.

@TODO @thruthesky pub.dev API reference 를 보고 그곳에 나와 있는 위젯들의 사용법을 설명한다.



## LabelField

TextField 를 좀 더 쓰기 편하게 해 놓은 것이다.



## UpdateBirthday

회원 정보 수정 페이지 등에서 회원의 생년월일 정보를 보여주고 수정하게 하려면 `UpdateBirthday` 위젯을 사용하면 된다. lable 과 description 을 줄 수 있다.

예제
```dart
UpdateBirthday(
    label: '생년월일',
    description: '본인 인증에 사용되므로 올바른 생년/월/일 정보를 선택해 주세요.',
)
```



## DisplayPhotos 사진 표시


배열에 URL 을 담아서 전달하면 화면에 사진을 표시 해 준다.

```dart
DisplayPhotos(urls: List<String>.from(v ?? []))
```



## 사용자 표시

Tile 형식으로 표현하기 위해서 `UserTile` 을 쓰면 된다. 사용자 모델이 있으면 `UserTile(user: UserModel)` 와 같이 표시하면 되고, 사용자 id 만 가지고 있다면, `UserTile.fromUid(uid)` 와 같이 호출하면 된다.

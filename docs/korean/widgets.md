# 위젯

fireship 에서 제공하는 기본 위젯에 대한 설명을 한다.

@TODO @thruthesky pub.dev API reference 를 보고 그곳에 나와 있는 위젯들의 사용법을 설명한다.

## LabelField

TextField 를 좀 더 쓰기 편하게 해 놓은 것이다.

예제
```dart
Theme(
  data: Theme.of(context).copyWith(
    inputDecorationTheme:
        Theme.of(context).inputDecorationTheme.copyWith(),
  ),
  child: LabelField(
    label: T.email.tr,
    controller: emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: const InputDecoration(
      prefixIcon: Icon(
        Icons.email,
      ),
    ),
  ),
),
```

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

## 사용자 정보 참고

로그인한 사용자를 포함한 사용자 정보를 화면에 표시 할 때에는 `UserDoc` 을 사용하면 된다.

UserDoc 은 다음과 같은 형태로 활용 할 수 있다.

- 사용자 문서를 가져와 화면에 표시하기
- 사용자 문서를 실시간으로 업데이트해서 화면에 표시하기. DB 의 값이 변하면 다시 build.
- 사용자 문서 중 특정 필드 하나를 화면에 표시하기
- 사용자 문서 중 특정 필드 하나를 실시간으로 업데이트해서 화면에 표시하기. DB 의 값이 변하면 다시 build 한다.

예제

```dart
UserDoc(uid: myUid!, builder: (user) => Text(user.displayName)),
UserDoc.sync(uid: myUid!, builder: (user) => Text(user.displayName)),
UserDoc.field(uid: myUid!, field: 'displayName', builder: (v) => Text(v.toString())),
UserDoc.fieldSync(uid: myUid!, field: 'displayName',  builder: (v) => Text(v.toString())),
```

참고로 실시간으로 데이터를 보여주지 않는 경우는 `cacheId` 를 통해서 데이터를 메모리에 캐시를 했다가 화면에 빠르게 표시 할 수 있다. 특히, setState 를 호출하는 경우 등에서 화면 반짝임을 줄일 수 있다.

예제 - `cacheId` 사용

```dart
UserDisplayName(uid: uid, cacheId: 'chatRoom'),
```

## 사용자 정보 캐시

때로는 사용자 정보를 표시 한 다음, setState 를 호출하면, 화면이 반짝 거리는 경우가 있다. 또는 계속 해서 DB 에 접속하는 것이 마음에 들지 않는 경우가 있을 수 있다. 이와 같은 경우, cacheId 를 사용하면, 해당 cacheId 위치에서는 해당 사용자의 값(또는 필드)를 메모리에 캐시하여 사용한다.

```dart
UserDoc(cacheId: 'home');
```

또는

```dart
UserDoc.field(
    cacheId: cacheId,
    uid: uid,
    field: Field.displayName,
    builder: (data) => Text(
      data
    ),
  );
```

/// UserDoc( ... )
/// UserDoc.sync(uid: user.uid, field: 'displayName', builder: (data, $) => Text(data)),
/// UserDoc.field( ... )
/// UserDoc.fieldSync( ...)

## 사용자 이름 표시

예제

```dart
 UserDisplayName(
  uid: userUid,
  user: user,
),
```

예제 - sync 를 사용해서 실시간 업데이트를 할 수 있다.

```dart
 UserDisplayName.sync(
  uid: userUid,
  user: user,
),
```

## 사용자 사진 표시

예제 - 사용자 사진 표시

```dart
UserAvatar(uid: userUid, size: 100, radius: 40),
```

에제 - 사용자 사진 실시간 업데이트하여 표시

```dart
UserAvatar.sync(uid: userUid, size: 100, radius: 40),
```

## 사용자 백그라운드 사진 표시

아래와 같이 간단히 표시 할 수 있다.

```dart
UserBackgroundImage(
  uid: userUid,
  user: user,
),
```

만약, realtime update 가 필요하면 아래와 같이 한다.

```dart
UserBackgroundImage.sync(
  uid: userUid,
  user: user,
),
```

## 사용자 상태 메세지 표시

예제

```dart
UserStateMessage(uid: ..., user: user),
```

예제 - sync 를 통한 실시간 업데이트

```dart
UserStateMessage.sync(
  uid: userUid,
  user: user,
),
```

## 버튼

본 항목에서는 각종 버튼들을 설명한다. 디자인이 마음에 들지 않으면 소스코드를 복사해서 수정하여 사용하면 된다.

### 좋아요 버튼

```dart
LikeButton(uid: userUid, user: user),
```

### 북마크 버튼

```dart
BookmarkButton(uid: userUid),
```

### 채팅 버튼

```dart
ChatButton(uid: uid),
```

### 신고 버튼

신고 버튼은 사용자, 글, 코멘트, 채팅 등을 신고 할 때 사용 할 수 있다.

예제 - 사용자 신고

```dart
ReportButton(uid: userUid),
```

### 차단 버튼

```dart
BlockButton(uid: userUid),
```


### 국가 정보 선택

`CountryPicker` 위젯을 통해서 국가를 선택 할 수 있다.

`initialValue` 옵션은 기본 선택 국가이다.

`filters` 는 선택 목록에 나타날 국가를 기록하는 것으로, 전체 목록을 사용자에게 보여주지 않고 몇 개만 제한 할 때 사용 할 수 있다.

`search` 는 검색이 가능하게 할지 검색이 안되게 할지 옵션이다.

`headerBuilder` 는 국가 선택 화면(다이얼로그) UI 에서 헤더 부분을 디자인 수정 할 수 있도록 한 것이다.

`itemBuilder` 는 선택 목록의 각 아이템 디자인을 할 수 있게 해 준다.

`labelBuilder` 는 선택된 항목을 화면에 표시 할 때, 디자인을 할 수 있도록 해 주는 것이다.

`onChanged` 는 사용자가 국가를 선택하면 호출되는 콜백 함수이다.



### 언어 선택

언어 선택은 국가 코드와 맞지 않아서 따로 만들었다. 예를 들어, 필리핀 언어에는 타갈로그어, 비사야어, 팜팡가어, 일롱고 등 대표적인 언어가 7개 정도 있다. 그 중에서 어느 언어를 선택해야 할지 매우 선택이 어렵다.

그래서, `LanguagePicker` 위젯을 통해서 언어를 선택 할 수 있도록 해 놓았다. 사용자가 자신의 언어를 변경하고자 하는 경우 사용하게 할 수 있다. 사용법은 `CountryPicker` 와 매우 흡사하다.

`LanguagePicker` 위젯은 내부적으로 `ElevatedButton` 을 사용하는데, 아래와 같이 `ListTile` 형태의 디자인으로 변경 할 수 도 있다.


```dart
SizedBox(
  width: double.infinity,
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                ///
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),

                /// 넓이를 꽉 채우기
                minimumSize: MaterialStateProperty.all(
                  const Size(double.infinity, 54),
                ),

                /// 내부 여백 지정
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16),
                ),

                /// 탭하면 (액티브) 바탕색 색깔을 엷은 회색으로 변경.
                /// overlayColor 로 변경함.
                overlayColor:
                    MaterialStateProperty.all(Colors.grey[300]),

                /// 글자를 왼쪽으로 넣기
                alignment: Alignment.centerLeft,

                /// 테두리 없애기
                elevation: MaterialStateProperty.all(0),

                /// 글자 크기. 색깔은 여기서 안됨.
                textStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: 16),
                ),

                /// 글자 색깔
                foregroundColor: MaterialStateProperty.all(
                  Colors.black,
                ),
              ),
            ),
          ),
          child: LanguagePicker(onChanged: (code) {}, search: true),
        ),
      ],
    ),
  ),
),
```


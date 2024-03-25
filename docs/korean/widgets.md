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

## 로그인한 사용자의 정보 표시

로그인한 사용자의 정보를 표시 할 때에는 아래와 같이 `MyDoc` 위젯을 사용하면 됩니다.

```dart
MyDoc(
  builder: (user) => user == null
      ? const SizedBox.shrink()
      : TextField(
          controller: nameController..text = user.displayName,
          decoration: const InputDecoration(
            labelText: '본명을 입력 해 주세요',
          ),
        ),
),
```

참고로, 아래는 MyDoc 을 쓰지 않고, UserDoc 을 써서 사용자 정보를 표시한 것입니다.
UserDoc 에는 사용자 UID 를 기록해 주어야하는데, 앱 부팅시에 로그인한 사용자의 UID 를 안전하게 얻으려면 `AuthReady` 를 통해서 로그인 사용자의 UID 가져오면 됩니다.

```dart
AuthReady(
  builder: (uid) => UserDoc.field(
    uid: uid,
    field: Field.displayName,
    builder: (v) {
      return TextField(
        controller: nameController..text = v ?? '',
        decoration: const InputDecoration(
          labelText: '본명을 입력 해 주세요',
        ),
      );
    },
  ),
),
```



## 다른 사용자 정보 참고

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

## 다른 사용자 정보 캐시

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

UserDoc( ... )
UserDoc.sync(uid: user.uid, field: 'displayName', builder: (data, $) => Text(data)),
UserDoc.field( ... )
UserDoc.fieldSync( ...)

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

사용자 사진을 표시 할 때에 `UserAvatar` 를 사용한다.

- `sync` 사용자 사진을 실시간으로 표시한다. 즉, 사용자 사진이 변경되면, 실시간으로 변경된 사진을 보여준다.


- `initialData` 는 이미지를 DB 에서 가져오기 전에 먼저 보여주는 것으로 사용자의 이미지 URL 값을 이미 알고 있다면, 이 값을 전달해 준다. 그러면 화면 깜빡임을 아주 많이 줄 일 수 있다.

- `cacheId` 는 사용자 사진이 깜빡이는 경우, 캐시 ID 를 사용하여 화면 깜빡임을 줄일 수 있다.
  단적인 예를 들면 채팅방에서, 메시지와 사진이 깜빡이는데, 이는 사진때문에 깜빡일 확률이 높다.
  특히 사진을 로드 할 때, 항상 로딩 중 위젯 표시가 되고, 사진이 표시된다.
  `cacheId` 는 `sync` 가 false 인 경우만 동작하는데, `UserDoc` 위젯을 통해서 캐시된 값을 재 사용한다.



  

예제 - 사용자 사진 표시

```dart
UserAvatar(uid: userUid, size: 100, radius: 40),
```

에제 - 사용자 사진 실시간 업데이트하여 표시

```dart
UserAvatar.sync(uid: userUid, size: 100, radius: 40),
```


에제 - 캐시하기. 사용자 사진의 깜빡임을 현저히 줄일 수 있다.

```dart
UserAvatar(
  uid: message.uid!,
  cacheId: message.uid,
  onTap: () {},
),
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


## SimplePhoneSignInForm

FireFlutter 는 Firebase Auth 의 Phone Sign-in 을 지원하는 전화 번호로 로그인 할 수 있는 간단한 UI 를 제공합니다. 참고로, 이 위젯은 편리한 테스트를 위해서 이메일 로그인도 지원합니다.


- 이 위젯은 (현재까지는) 국가 전화 코드 선택을 지원하지 않습니다. 따라서 국가 코드 선택이 필요한 경우, 이 위젯의 코드를 복사해서 수정해서 사용하면 됩니다.

- 리뷰 또는 테스트를 위해서 [emailLogin], [reviewEmail], [reviewPassword], [reviewPhoneNumber], [reviewRealPhoneNumber], [reviewRealSmsCode] 와 같은 값을 사용 할 수 있습니다. 만약 리뷰나 테스트 용 로그인이 아니면, 이 값들은 필요없으므로 옵션 지정 할 필요가 없습니다.

- [emailLogin] 이메일 로그인을 할 수 있게 해 줍니다. 이 값이 true 로 지정되고, 전화번호에 @ 이 포함되어 있으면, 이메일과 비밀번호로 로그인을 합니다. 이메일과 비밀번호는 `:` 로 분리해서 입력하면 됩니다. 예를 들어, `my@email.com:4321Pw` 와 같이 하면, 메일 주소는 my@email.com 이고, 비밀번호는 4321Pw 가 됩니다.

- [reviewEmail] Review 용 임시 이메일. 이 옵션에 메일 주소를 "abcdefg@review.com" 와 같이 지정해 놓고, 사용자가 입력 창에 이 메일 주소를 입력하면 리뷰 계정으로 로그인을 합니다. 물론, 메일 계정은 이미 Firebase Auth 에 생성되어져 있어야 합니다.

- [reviewPhoneNumber] 나 [reviewRealPhoneNumber] 를 입력하면, 이 이메일 계정으로 로그인합니다.

- [reviewPassword] 는 [reviewEmail] 과 함께 사용되는 리뷰용 임시 비밀번호. [emailLogin] 이 true 인 경우, "[reviewEmail]:[reviewPassword]" 와 같이 입력하면, 리뷰 계정으로 로그인합니다.

- [reviewPhoneNumber] Review 용 임시 전화번호. 이 값을 전화번호로 입력하면, 리뷰 계정으로 자동 로그인. 예를 들어, 이 값이 '01012345678' 으로 지정되고, 사용자가 이 값을 입력하면, 곧 바로 리뷰 [reviewEmail] 계정으로 로그인합니다. SMS 코드를 입력 할 필요 없이, 바로 로그인합니다.

- [reviewRealPhoneNumber] 테스트 전화번호. 이 값을 전화번호로 입력하면, 테스트 SMS 코드를 입력하게 합니다. 예를 들어, 이 값이 '01012345678' 으로 지정되고, 사용자가 이 값을 입력하면, 테스트 SMS 코드를 입력하게 합니다.

- [reviewRealSmsCode] 리뷰 할 때 사용하는 SMS 코드. [reviewRealPhoneNumber] 를 입력 한 다음, 이 값을 SMS 코드로 입력하면, [reviewEmail] 계정으로 자동 로그인. 즉, [reviewRealPhoneNumber] 을 입력하고, [reviewRealSmsCode] 를 입력하면, 테스트 계정으로 로그인하빈다. 이것은 애플 리뷰에서 리뷰 계정 로그인을 할 때, 로그인 전체 과정을 다 보여달라고 하는 경우, 이 [reviewRealPhoneNumber] 와
[reviewRealSmsCode] 를 알려주면 됩니다.

- [onCompleteNumber] 전화번호 입력을 하고, 전송 버튼을 누르면 이 콜백을 호출합니다. 이 콜백은 전화번호를 받아서,
전화번호가 올바른지 또는 전화번호를 원하는 형태로 수정해서 반환하면 됩니다. 예를 들어, 한국 전화번호와 필리핀 전화번호 두 가지만 입력
받고 싶은 경우, 한국 전화번호는 010 로 시작하고, 필리핀 전화번호는 09로 시작한다. 그래서 전화번호의 처음 숫자를 보고
+82 또는 +63을 붙여 완전한 국제 전화번호로 리턴하면 됩니다. 만약, 이 함수가 null 을 리턴하면, 에러가 있는 것으로 판단하여 동작을 멈춥니다.

- [phoneNumberDisplayBuilder] 는 전화번호 입력을 완료하고, SMS 코드를 입력하는 화면에서, 전화번호를 어떻게 표시할지
결정하는 함수입니다. 이 함수는 일반적으로 국제 전화 번호 포멧의 문자열 값을 받아서, 사용자에게 보기 쉽게 적절히 수정해서 리턴하는 역할을 합니다.
예를 들어, 사용자가 입력한 전화번호(또는 국제 전화번호)가 +821012345678 이면, 이 국제 전화번호 문자열을 받아서, 사용자가 보기/읽기 쉽게 010-1234-5678 로 리턴하면 화면에 010-1234-5678 이 표시됩니다. 이 함수가 null 이면, 전화번호를 그대로 표시합니다.

- [onSignin] 로그인이 성공하면 호출되는 콜백. 사용자가 로그인을 했으므로, 홈 화면으로 이동하거나 기타 작업을 할 수 있습니다. 참고로, 로그인이 성성하면 이 위젯은 UserService.instance.login() 을 호출합니다. 그리고 처음 로그인이면, 이 함수에서 /users/<uid> 를 생성를 생성합니다.

- [headline] 상단에 표시할 헤드라인 위젯. 이 값이 null 이면 기본 텍스트가 표시된다. 기본 텍스트는 다국어 번역이 지원이 됩니다.

- [label] 전화번호 입력 박스 위에 표시될 레이블

- [description] 전화번호 입력 박스 아래에 표시될 설명


아래의 예제는 SimplePhoneSignInForm 을 사용하는데, Theme 을 사용하여 UI 를 변경하는 예제이다.

```dart
Theme(
  data: Theme.of(context).copyWith(
    inputDecorationTheme:
        Theme.of(context).inputDecorationTheme.copyWith(
              hintStyle: TextStyle(
                color: context.colorScheme.secondary,
                fontSize: fsXl,
              ),
            ),
    textTheme: Theme.of(context).textTheme.copyWith(
          bodyLarge: TextStyle(
            color: context.colorScheme.secondary,
            fontSize: fsXl,
          ),
        ),
  ),
  child: SimplePhoneSignInForm(
    emailLogin: true,
    prefix: const Text('010 '),
    reviewPhoneNumber: '12345678',
    reviewRealPhoneNumber:
        '+821011112222', // 화면에는 11112222 로 입력 하면 됨.
    reviewRealSmsCode: '123456',
    onCompleteNumber: (phoneNumber) {
      String number = phoneNumber.trim();
      number = number.replaceAll(RegExp(r'[^\+0-9]'), '');
      number = number.replaceFirst(RegExp(r'^0'), '');
      number = number.replaceAll(' ', '');
      number = number.replaceAll('-', '');
      number = number.replaceAll('(', '');
      number = number.replaceAll(')', '');

      if (number.length == 8) {
        return "+8210$number";
      } else if (number == '12345678') {
        // 리뷰 전화번호
        return number;
      } else {
        error(
          context: context,
          title: '전화번호 입력 오류',
          message: '전화번호를 올바로 입력하세요.',
        );
      }
      return null;
    },
    onSignin: () => signinSuccess(context),
    languageCode: 'ko',
    headline:
        Text(' 간편하게 전화번호 로그인을 합니다.', style: context.bodySmall),
    label: Text('  전화번호', style: context.labelSmall),
    hintText: '',
    description: Text(
      '  전화번호를 입력하시면 인증 요청 버튼을 나타납니다.',
      style: context.labelSmall,
    ),
    phoneNumberDisplayBuilder: (n) {
      if (n?.contains('+8210') == true) {
        n = n?.replaceFirst('+8210', '');
        n = '010-${n?.substring(0, 4)}-${n?.substring(4, 8)}';
        return n;
      } else {
        return n;
      }
    },
    submitLabel: const Text('     인증 요청     '),

    smsPhoneLabel: Text('  전화번호', style: context.labelSmall),
    smsDescription:
        Text('  인증번호를 입력하세요.', style: context.labelSmall),
    smsSubmitLabel: const Text('   인증번호 전송   '),
    smsRetry: Text(
      '다시하기',
      style: context.labelLarge
          .copyWith(color: context.colorScheme.secondary),
    ),
  ),
),
```


## PopupTextField


`PopupTextField` 는 TextField 와 비슷한 동작을 하는데, TextField 의 레이블이나 입력 박스 UI 대신에 두 줄로된 레이블과 값을 표시하고, 터치를 하면 새창을 열어, 사용자로 부터 문자열을 입력을 받습니다. TextField 과 비슷하게 동작하면서 UI/UX 적으로 분명한 차이를 보이는데, 공간 절약을 할 수 있다는 장점이 있습니다.

활용 예를 들면, AppBar 의 bottom 이나, 각종 양식에서 새창을 띄워서 입력을 받고 싶은 경우에 사용 할 수 있습니다.

`controller` 는 TextEditingController 이며, 필수 값입니다. 실제 TextField 에서 동작하는 것과 비슷하게 동작합니다.

`onChange` 는 사용자가 텍스트 입력을 통해 변경 했을 때, 변경된 텍스트 값이 넘어오는 콜백 함수입니다. 만약, 사용자가 텍스트 필드에서 값을 변경하지 않고, 그대로 OK 를 누르거나, Cancel 하거나, 팝업창을 닫을 때에는 `onChange` 가 호출되지 않습니다.


```dart
PopupTextField(
  controller: searchController,
  label: '검색어',
  typeHint: '검색어를 입력하세요',
  onChange: (value) => research(search: value),
),
```





## PopupSelectField

팝업 다이얼로그 창을 띄운 후 여러 개의 목록 아이템 중에서 하나를 선택 할 수 있습니다. 플러터에서 이미 존재하는 PopupMenuButton 이나 BottomSheet 과 유사하게 동작하는데, 차이점은 UI/UX 가 최대한 PopupTextField 와 유사하게 되어져 있어 통일된 디자인을 하고자 할 때 PopupTextFiled 와 함께 사용하면 좋습니다.

기본적으로 텍스트 레이블과 값이 PopupTextField 와 동일하게 나타나며, 텍스트를 터치하면 팝업창이 뜨고, 목록한 값들 중에서 하나를 선택 할 수 있습니다.
label 의 값은 기본 UI 에 레이블 처럼 나오며, 팝업 창의 제목으로 나옵니다.

typeHint 는 기본 값이 없는 경우, 힌트로 표시되며, 기본 값인 [initialValue] 가 지정되거나 사용자가 값을 변경(선택)하면 사라집니다. typeHint 는 팝업창에서 label 밑에 표시되며, 설명으로 사용됩니다.

`initialValue` 는  초기값입니다.  그리고 팝업창 목록에서 해당 값이 선택되어져 보입니다.

`onChange` 는 선택 목록에서 값이 변경(선택) 될 때 호출되는 콜백 함수입니다. initialValue 가 지정되면 위젯이 inflate 될 때, 최초 1회 자동 호출됩니다.


예제

```dart
PopupSelectField(
  label: '근무형태',
  initialValue: '전체',
  typeHint: '근무형태를 선택하세요',
  items: ['전체', '정규직', '비정규직', '계약직'],
  onChange: print,
),
```



## TextWithLabel

텍스트와 레이블을 보여주고, 탭을 할 수 있도록 한다. 기본적인 UI/UX ListTile 과 흡사하다. 꼭 필요한 경우가 아니면, ListTile 을 사용할 수도 있겠다.



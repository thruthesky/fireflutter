# Fireship 에서 제공하는 함수들

These functions are provided to be used anywhere in the code as needed.

## 에러 표시 함수

주로 아래의 두가지 방식으로 에러를 화면에 표시 할 수 있다.

- `error` 함수는 showDialog 를 이용해서, `ErrorDialog` 를 화면에 에러를 표시한다.
- `errorToast` 는 `toast` 를 이용해서, 화면에 에러를 표시한다.

## toast

Toast can be used to show a snackbar with a message.

```dart
toast(context: context, message: 'Hello User.');
```

Parameters:

- context
    - required BuildContext
    - the build context of the current widget
- title
    - String
    - title text of the snackbar
- message
    - required String
    - message to show as text
- icon
    - Icon
    - The icon to add in the snackbar
- duration
    - Duration
    - how long does the snackbar shows?
    - default: const Duration(seconds: 8)
- onTap
    - Function(Function)
    - on tap function
- error
    - bool
    - is it an error message?
- hideCloseButton
    - bool
    - default: false
- backgroundColor
    - Color
- foregroundColor
    - Color
- runSpacing
    - double
    - default: 12
    - spacing between the icon and the message

## confirm

The `confirm` is a prompt that will let the user choose from yes or no.

```dart
final re = await confirm(
    context: context,
    title: 'Delete Account',
    message: 'Are you sure you want to delete your account?'
);
```

The `re` in the example will be a nullable bool. If `re` is `true` means user chooses yes. If `false` means user chooses no. If `null` means neither user chooses yes nor no.

Parameters:

- [required] BuildContext context
- [required] String title
    - title of the message
- [required] String message
    - Add the question or confirmation message here.

## input

The `input` function can be used to ask for an input from user.

```dart
final re = await input(
    context: context,
    title: 'Name',
    subtitle: 'Enter your lovely name',
    hintText: 'Last Name, First Name',
);
```

Parameters:

- [required] BuildContext context
- [required] String title
    - The title of the prompt
- String subtitle
    - The subtitle or additional info for input box
- [required] String hintText
    - hintText for the input box
- String initialValue
    - the default input value




## 로케일 - 언어

아래와 같이 언어 정보를 가져 올 수 있다. `currentLocale` 은 `devicelocale` 의 `Devicelocale.currentLocale` 을 짧게 표현한 것으로 현재 핸드폰의 언어를 가져온다. `preferredLanguages` 는 핸드폰에 설정된(추가된) 언어 목록을 가져온다.

참고로, `Devicelocale.currentLocale` 과 `Devicelocale.preferredLanguages` 는 `en-PH` 과 같이 로케일 전체 문자열을 리턴하지만 `currentLocale` 과 `preferredLanguages` 는 `en` 과 같이 두 글자 언어 코드만 리턴한다.

```dart
(() async {
  final locale = await currentLocale;
  print('locale: $locale');
  final locales = await preferredLanguages;
  print('locales: $locales');
})();
```

결과
```dart
locale: en
locales: [en, ko]
```

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

## 확인 다이얼로그 - Confirm Dialog

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



아래와 같이 커스터마이징을 할 수 있다.

```dart
/// Dialog 커스텀 설정
FireFlutterService.instance.init(
  confirmDialog: ({
    required BuildContext context,
    required String? title,
    required String message,
  }) async {
    return await showDialog<bool?>(
      context: context,
      builder: (context) => SilverConfirmDialog(
        title: title,
        message: message,
      ),
    );
  },
);
/// Dialog UI 디자인
import 'package:flutter/material.dart';
import 'package:silvers/font_awesome/lib/font_awesome_flutter.dart';
import 'package:silvers/global.dart';

class SilverConfirmDialog extends StatelessWidget {
  const SilverConfirmDialog({
    super.key,
    this.title,
    required this.message,
  });

  final String? title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      content: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.onPrimary,
              border: Border.all(
                color: context.colorScheme.primary,
                width: 1.8,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              color: context.colorScheme.primaryContainer.withAlpha(50),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: context.titleMedium,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: context.labelSmall,
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('거절'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                border: Border.all(
                  color: context.colorScheme.primary,
                  width: 1.8,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.exclamation,
                  color: context.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 호출하기
TextButton(
  onPressed: () async {
    final re = await confirm(
        context: context,
        title: '확인 또는 거절',
        message: '확인 또는 거절을 설명....');
    print("confirm dialog closed with: $re");
  },
  child: const Text('Confirm Dialog'),
);
```


## 에러 다이얼로그 표시

아래와 같이 표시 할 수 있다.

```dart
return TextButton(
    onPressed: () async {
    await error(
        context: context, title: '에러 제목', message: '에러를 설명할 메시지...');
    print("error dialog closed");
    },
    child: const Text('Error Dialog'),
);
```


아래와 같이 커스텀 디자인을 할 수 있다.

```dart
FireFlutterService.instance.init(
  errorDialog: ({
    required BuildContext context,
    required String? title,
    required String message,
  }) async {
    return await showDialog<bool?>(
      context: globalContext,
      builder: (context) => SilverErrorDialog(
        title: title,
        message: message,
      ),
    );
  },
);


import 'package:flutter/material.dart';
import 'package:silvers/font_awesome/lib/font_awesome_flutter.dart';
import 'package:silvers/global.dart';

class SilverErrorDialog extends StatelessWidget {
  const SilverErrorDialog({
    super.key,
    this.title,
    required this.message,
  });

  final String? title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      content: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.onPrimary,
              border: Border.all(
                color: context.colorScheme.error,
                width: 1.8,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              color: context.colorScheme.errorContainer.withAlpha(50),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: context.titleMedium,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: context.labelSmall,
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: context.colorScheme.errorContainer,
                border: Border.all(
                  color: context.colorScheme.error,
                  width: 1.8,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.exclamation,
                  color: context.colorScheme.error,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```


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




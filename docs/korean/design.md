# 디자인

- FireFlutter 가 제공하는 위젯들은 기본 디자인을 포함하고 있으며 플러터 theme 지정 방식을 이용하여 원하는데로 디자인을 변경 할 수 있습니다. 이 말은 FireFlutter 가 제공하는 위젯의 디자인을 변경하려면 플러터의 theme 디자인을 하면 된다는 것이다.

- 기본적으로 제공하는 Theme 디자인이 있는데, `defaultLightTheme()` 을 MaterialApp 에 연결하여 사용 할 수 있습니다.

예제
```dart
MaterialApp(
    theme: defaultLightTheme(context: context)
)
```


- `LabelField` 라는 위젯이 있는 데 를 Theme 디자인하기 위해서는 최상위 THeme 설정에 해도 되고, 아래와 같이 개별적으로 Theme 설정을 할 수 있다.

```dart
Theme(
  data: Theme.of(context).copyWith(
    inputDecorationTheme:
        Theme.of(context).inputDecorationTheme.copyWith( /* ... */ ),
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

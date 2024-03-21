# 디자인

- FireFlutter 의 목적은 사용자, 게시판, 채팅 등의 기능 적인 부분 뿐만아니라, 멋진 디자인의 위젯을 제공하여 UI/UX 작업을 편하게 할 수 있도록 하기 위함입니다. 본 문서의 내용을 잘 보시면 FireFlutter 의 기본 디자인을 잘 활용 할 수 있으며, 자신만의 디자인으로 응용해서 쓸 수 있습니다.

- 특히 중요한 것은 플러터의 Theme 방식을 이용하여 원하는데로 디자인을 변경 할 수 있습니다. 이 말은 FireFlutter 가 제공하는 위젯의 디자인을 변경하려면 플러터의 Theme 디자인을 하면 된다는 것입니다.

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


## 테마 설정 한눈에 보기

때로는 현재 앱(여러분들이 개발중인 앱)의 테마가 어떻게 설정되어져 있는지 한눈에 보면 도움이 될 때가 있습니다. 아래와 같이 ThemeScreen 을 보면, TextTheme 이나 ColorTheme 등을 볼 수 있습니다. 실제 개발 작업을 할 때에는 아래의 화면을 캡쳐해 놓고 필요할 때 마다 빠르게 참조하시길 권장합니다.

```dart
ElevatedButton(
  onPressed: () {
    showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) => const ThemeScreen(),
    );
  },
  child: const Text("Color theme"),
)
```


## 사진 업로드 팝업창 UI 디자인 변경


![RoundCarouseEntry](https://github.com/thruthesky/social_kit/blob/main/images/default_upload_selected_bottom_sheet_1.jpg?raw=true)



```dart
StorageService.instance.init(
  customize: StorageCustomize(
    uploadSelectionBottomsheetBuilder: ({
      required BuildContext context,
      required bool camera,
      required bool gallery,
    }) {
      return Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: Theme.of(context).listTileTheme.copyWith(
                dense: false,
                visualDensity: VisualDensity.standard,
                titleTextStyle: context.titleMedium,
              ),
        ),
        child: DefaultUploadSelectionBottomSheet(
          camera: camera,
          gallery: gallery,
          padding: const EdgeInsets.all(24),
          spacing: 16,
        ),
      );
    },
  ),
);
```
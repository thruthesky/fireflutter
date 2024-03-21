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


아래에서 왼쪽 사진은 테마 디자인 및 커스텀 디자인 설정을 하지 않은 것입니다. 경우에 따라서는 기본 UI 를 그대로 써도 되지만, 오른쪽 사진과 같이 약간 변화를 주고 싶은 경우가 있습니다.

![DefaultUploadSelectedBottomSheet](https://github.com/thruthesky/fireflutter/blob/main/docs/assets/images/default_upload_selected_bottom_sheet_2.jpg?raw=true)


예제 - 커스텀 디자인을 하는 예제


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

원한다면 `DefaultUploadSelectionBottomSheet` 소스 코드를 복사해서 모든 것을 변경해도 됩니다.




## 디자인 작업 편리하게 하기

UI 커스터마이징 작업을 할 때, 코드를 약간 수정하면 곧 바로 화면에 적용되어 눈으로 볼 수 있어야 하는데 그렇지 못한 경우가 발생합니다. 이와 같은 경우, 작업을 편리하기 위해서 테스트 코드를 initState 등에 기록하여, 화면 reload 를 통해서, 빠르게 디자인 변경 사항을 확인을 할 수 있습니다.

```dart
@override
void initState() {
  super.initState();
  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    Timer(const Duration(milliseconds: 100), () {
      StorageService.instance.chooseUploadSource(context: context);
    });
  });
}
```

또는 `build` 함수에 코드를 임시로 집어 넣고, UI 디자인 작업이 끝나면 적당한 위치로 옮기셔도 됩니다.



## 채팅 메시지 버블 디자인


```dart
ChatService.instance.init(
  customize: ChatCustomize(
    chatBubbleBuilder: ({
      required context,
      required message,
      required onChange,
    }) =>
        Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
              bodyMedium:
                  Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14,
                      ),
            ),
      ),
      child: Text(
        message.text ?? '',
        style: context.titleLarge,
      ),

    ),
  ),
);
});
```
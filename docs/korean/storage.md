# 스토리지

- Firebase 의 Storage 서비스에 업로드를 하는 기능이다.
- 업로드는 일반적으로 `StorageService.instance.upload` 함수를 통해서 하면 된다. 이 함수를 호출하면 팝업창으로 갤러리에서 업로드 할 지, 카메라로 부터 업로드 할 지 선택을 할 수 있는 창이 뜨며, 사용자가 선택을 하면 업로드를 진행한다.

## 업로드하기

아래는 업로드하는 예제이다. 버튼을 클릭하면 `StorageService.instance.upload` 함수를 호출하여 업로드를 한다. 필요한 상황에서 그냥 upload 함수를 호출하기만 하면 된다. 특히 compressQuality 와 maxWidth, maxHeight 을 통해서 이미지의 사이즈와 저장 용량을 적절히 조절 할 수 있다.

```dart
IconButton(
    icon: widget.cameraIcon ?? const Icon(Icons.camera_alt),
    onPressed: () async {
        // This is the upload
        final url = await StorageService.instance.upload(
            context: context,
            camera: true,
            gallery: true,
            compressQuality: 70,
            maxWidth: 800,
            maxHeight: 800,
        );
        if (url == null) return;
        print("Your uploaded file url is $url");
    },
),
```

파일이 저장되는 경로는 특별히 경로 지정을 하지 않는 한 Storage 의 `/users/<uid>` 에 저장된다.


## 업로드한 파일 삭제

다음은 업로드한 파일을 삭제하는 것이다.

```dart
final url = await StorageService.instance.upload( ... );

// Delete existing image
await StorageService.instance.delete(url);
```

## Accessing

In accessing the file, it will depend on the type of the file that was uploaded. It is important to know that we need to save the url of the uploaded file since we need it to access the file.

For instance, we have uploaded a photo and we want to access it in the app:

```dart
CachedNetworkImage(
    imageUrl: savedUrl,
);
```

Choose the correct widget for the file type.

## 데이터베이스 URL 값 변경

이미지를 stroage 에 업로드하면 그 경로를 데이터베이스의 특정 위치(노드)에 저장을 해 놓는 것이 일반적이다. 때로는 업로드한 이미지를 삭제하고 다른 이미지로 변경하고자 하는 경우가 있다. 이 때, 사용할 수 있는 것이 `uploadAt` 이다.

만약, `uploadAt` 을 사용하지 않으면 아래와 같이 코딩을 할 수 있다.

```dart
// 이미지 업로드
final url = await StorageService.instance.upload(
    context: context,
    progress: (p) => setState(() => progress = p),
    complete: () => setState(() => progress = null),
);
if (url == null) return;

// 기존 이미지 URL 보관
final oldUrl = UserService.instance.user?.photoUrl;

// 새로운 이미지 URL 을 DB 에 저장
await user.update(
    photoUrl: url,
);

// 기존 이미지 삭제
await StorageService.instance.delete(oldUrl);
```

위와 같은 코드(기존 이미지 삭제 후 새로운 이미지 저장)를 보다 간단하게 아래와 같이 할 수 있다.

```dart
await StorageService.instance.uploadAt(
    context: context,
    path: "users/${user.uid}/photoUrl",
    progress: (p) => setState(() => progress = p),
    complete: () => setState(() => progress = null),
);
```

위와 같이 하면 `path` 에 존재하는 이미지를 삭제하고, 새로운 이미지를 업로드한 다음, 그 경로(URL)를 `path` 에 업데이트 한다. 즉, 보다 짧은 코드로 가능하다.


## 디자인 변경

`StorageService.instance.uploadAt` 와 같이 이미지를 업로드 할 때, bottom sheet 가 열린다. 이 때 bottom sheet 에 카메라, 갤러리 등의 선택을 ListTile 로 쓰는데 디자인이 마음에 들지 않는다면, Theme 설정을 통해서 변경 해 줄 수 있다.

예를 들면 아래는 `UserAvatarUpdate` 위젯을 터치하면 사용자의 프로필 사진을 변경하는데, 내부적으로 `uploadAt` 함수를 호출한다. 그래서 UI 변경을 위해서는 아래와 같이 상위 위젯에 Theme 설정을 할 수 있다.

```dart
ListTileTheme(
  tileColor:
      Theme.of(context).colorScheme.surfaceContainerLow,
  child: const UserAvatarUpdate(size: 140),
),
```



## 에러 핸들링

사용자가 파일 업로드를 할 때, 갤러리나 카메라 등으로 부터 사진을 업로드 할 수 있는데, 권한을 허용하지 않고 거절하면, 미디어(사진 등)을 선택 할 수 없다. 앱 내부적으로 exception 이 발생한다. 기본적으로 FireFlutter 에서 이 권한에 대한 에러를 핸들링한다. 만약, 직접 에러 핸들링을 하고 싶은 경우 아래와 같이 하면 된다.

```dart
StorageService.instance.init(
  enableFilePickerExceptionHandler: false,
)
```

위와 같이 `enableFilePickerExceptionHandler` 에 false 값을 주면, FireFlutter 가 exception 을 핸들링하지 않고 그대로 던져버린다. 개발자는 모든 에러를 캡쳐하는 루틴(`Global Error Handler`)을 만들어서 적절하게 처리를 해야 한다.



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

## Replacing

There are times that the app needs to replace existing image, In this case, it needs to delete the exsiting images like below.

```dart
// Upload
final url = await StorageService.instance.upload(
    context: context,
    progress: (p) => setState(() => progress = p),
    complete: () => setState(() => progress = null),
);
if (url == null) return;

final oldUrl = UserService.instance.user?.photoUrl;

await user.update(
    photoUrl: url,
);

// Delete existing image
await StorageService.instance.delete(oldUrl);
```

For the replacement of exisiting (or file), you can use `uploadAt` to make it simplifying. It will replace the image at the path.

```dart
await StorageService.instance.uploadAt(
    context: context,
    path: "users/${user.uid}/photoUrl",
    progress: (p) => setState(() => progress = p),
    complete: () => setState(() => progress = null),
);
```

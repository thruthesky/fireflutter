# Storage

To upload an image, you may use `StorageService.instance.upload` method.

## Uploading

This is an example of an Button that will upload a file.

```dart
IconButton(
    icon: widget.cameraIcon ?? const Icon(Icons.camera_alt),
    onPressed: () async {
        // This is the upload
        final url = await StorageService.instance.upload(
            context: context,
            camera: true,
            gallery: true,
        );
        if (url == null) return;
        print("Your uploaded file url is $url");
    },
),
```

## Deleting

This is an example of deleting a file using URL.

```dart
final oldUrl = "firebase.url.photo.com";

// Delete existing image
await StorageService.instance.delete(oldUrl);
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


## Customization

If you want to create your own design for you own upload bottomsheet you can do so by initializing `StorageService.instance`
and updating the `uploadSelectionBottomsheetBuilder`, this will allow you to completely customize the upload bottomsheet. see example
bellow


```dart
StorageService.instance.init(customize: StorageCustomize(
    uploadSelectionBottomsheetBuilder: (
        {required bool camera,
        required BuildContext context,
        required bool gallery}) {
        // Your implementation
            return Builder(builder: (context) {
            return const ListTileTheme(
            child: DefaultUploadSelectionBottomSheet(
            camera: true,
            gallery: true,
            ));
        });
    },
));
```

## Error Handling

When a user uploads a file, he or she can upload a photo from the gallery or camera, but if permission is not granted and the user refuses, the media (photo, etc.) cannot be selected. An exception occurs internally in the app. By default, FireFlutter handles errors regarding this permission. If you want to handle errors yourself, you can do it as follows.

```dart
StorageService.instance.init(
  enableFilePickerExceptionHandler: false,
)
```

If you give a false value to `enableFilePickerExceptionHandler` as above, FireFlutter does not handle the exception and throws it as is. Developers must create a routine (`Global Error Handler`) to capture all errors and handle them appropriately.
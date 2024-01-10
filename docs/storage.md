# Storage

To upload an image, you may use `StorageService.instance.upload` method.

## Uploading

<!-- TODO DOCS -->

## Deleting

<!-- TODO DOCS -->

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

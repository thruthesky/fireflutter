# Upload

## Customizing source

You can limit the uploaded sources. You can choose camera, gallery, or files like below.

```dart
ChatService.instance.init(
  uploadFromCamera: true,
  uploadFromGallery: true,
  uploadFromFile: false,
);
PostService.instance.init(
  uploadFromCamera: false,
  uploadFromGallery: true,
  uploadFromFile: false,
);
CommentService.instance.init(
  uploadFromCamera: true,
  uploadFromGallery: false,
  uploadFromFile: false,
);
```


## Uploading a photo

Below is an example of uploading a photo into Firebase storage. You can get the progress and the url.

```dart
IconButton(
  onPressed: () async {
    final url = await StorageService.instance.upload(
      context: context,
      file: false,
      progress: (p) => progressEvent.add(p),
      complete: () => progressEvent.add(null),
    );
    my?.update(stateImageUrl: url);
  },
  icon: const Icon(Icons.camera_alt),
),
```
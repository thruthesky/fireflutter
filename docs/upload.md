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
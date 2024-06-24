import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  ///
  StorageService._();

  StorageCustomize customize = StorageCustomize();

  /// [enableFilePickerExceptionHandler] is a flag to enable the exception
  /// handler. If it is true, it will show an error toast message when the user
  /// denies the permission to access the camera or the gallery. By default,
  /// it is true. If you want to handle the exception by yourself, set it to
  /// false.
  bool enableFilePickerExceptionHandler = true;

  init({
    StorageCustomize? customize,
    bool? enableFilePickerExceptionHandler,
  }) {
    if (customize != null) {
      this.customize = customize;
    }
    if (enableFilePickerExceptionHandler != null) {
      this.enableFilePickerExceptionHandler = enableFilePickerExceptionHandler;
    }
  }

  /// Upload a file (or an image) to Firebase Storage.
  ///
  /// This method must be the only method that upload a file/photo into Storage
  /// or, the listing photos from `/storage` will not work properly.
  ///
  /// 범용 업로드 함수이며, 모든 곳에서 사용하면 된다.
  ///
  /// [path] is the file path on mobile phone(local storage) to upload.
  ///
  ///
  /// It returns the download url of the uploaded file.
  ///
  /// [progress] is a callback function that is called whenever the upload progress is changed.
  ///
  /// [complete] is a callback function that is called when the upload is completed.
  ///
  /// [compressQuality] is the quality of the compress for the image before uploading.
  /// 중요, compresssion 을 하면 이미지 가로/세로가 자동 보정 된다. 따라서 업로드를 하는 경우, 꼭 사용해야 하는 옵션이다.
  /// 참고로 compression 은 기본 이미지 용량의 내용에 따라 달라 진다.
  /// 이 값이 22 이면, 10M 짜리 파일이 140Kb 로 작아진다.
  /// 이 값이 70 이면, 30M 짜리 파일이 1M 로 작아진다.
  /// 이 값이 80 이면, 10M 짜리 파일이 700Kb 로 작아진다. 80 이면 충분하다. 기본 값이다.
  /// 이 값이 0 이면, compress 를 하지 않는다. 즉, 원본 사진을 그대로 올린다.
  ///
  /// [saveAs] is the path for the uploaded file to be saved in Firebase Storage.
  /// If it is null, it will be uploaded to the default path.
  ///
  /// This method does not handle any exception. You may handle it outisde if you want.
  ///
  Future<String?> uploadFile({
    Function(double)? progress,
    Function? complete,
    // Updated the default into zero
    // because videos and files will have problem
    // if we compress them using FlutterImageCompress.
    int compressQuality = 0,
    String? path,
    String? saveAs,
    String? type,
  }) async {
    if (path == null) return null;
    File file = File(path);
    if (!file.existsSync()) {
      dog('File does not exist: $path');
      throw Exception('File does not exist: $path');
    }

    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef
        .child(saveAs ?? "users/${myUid!}/${file.path.split('/').last}");
    // Review: Here only Image can be compressed. File and Video cannot be compressed.
    // It may cause error if you try to compress file or video.
    // So, we should check the file type before compressing.
    // Or... add custom compressing function for file and video, and/or image.
    if (compressQuality > 0) {
      final xfile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.absolute.path}.compressed.jpg',
        quality: 100 - compressQuality,
      );
      file = File(xfile!.path);
    }
    final uploadTask = fileRef.putFile(file);
    if (progress != null) {
      uploadTask.snapshotEvents.listen((event) {
        double rate = event.bytesTransferred / event.totalBytes;
        progress(rate < 0.2 ? 0.2 : rate);
      });
    }

    /// wait until upload-complete
    await uploadTask.whenComplete(() => complete?.call());
    final url = await fileRef.getDownloadURL();
    // print(fileRef.fullPath);

    return url;
  }

  /// Delete the uploaded file in Firebase Storage by the url.
  ///
  /// If the url is null, it does nothing.
  ///
  /// It will produce an Exception on error.
  Future<void> delete(String? url) async {
    if (url == null || url == '') return;
    final storageRef = FirebaseStorage.instance.refFromURL(url);
    await storageRef.delete();

    return;
  }

  /// 이미지 업로드 소스(갤러리 또는 카메라) 선택창을 보여주고, 선택된 소스를 반환한다.
  ///
  /// [camera] 는 카메라를 선택할 수 있게 할지 여부이다.
  /// [gallery] 는 갤러리를 선택할 수 있게 할지 여부이다.
  ///
  /// 사용자에게 사진/파일 업로드를 요청한다.
  ///
  /// 커스텀 디자인은 [customize] 에서 할 수 있다.
  Future<ImageSource?> chooseUploadSource({
    required BuildContext context,
    bool camera = true,
    bool gallery = true,
  }) async {
    return await showModalBottomSheet(
      context: context,
      builder: (_) =>
          customize.uploadSelectionBottomsheetBuilder?.call(
            context: context,
            camera: camera,
            gallery: gallery,
          ) ??
          DefaultUploadSelectionBottomSheet(
            camera: camera,
            gallery: gallery,
          ),
    );
  }

  /// Update photos in the Firebase Storage.
  ///
  /// 사용자에게 사진/파일 업로드를 요청한다.
  ///
  /// 1. It displays the upload source selection dialog (camera or gallery).
  /// 2. It picks the file
  /// 3. It compresses the file
  /// 4. It uploads and calls back the function for the progress indicator.
  /// 5. It returns the download url of the uploaded file.
  ///
  /// If the user cancels the upload, it returns null.
  ///
  /// Ask user to upload a photo or a file
  ///
  /// Call this method when the user presses the button to upload a photo or a file.
  ///
  /// This method does not handle any exception. You may handle it outisde if you want.
  ///
  /// [path] is the file path on mobile phone(local storage) to upload.
  ///
  /// [saveAs] is the path on the Firebase storage to save the uploaded file.
  /// If it's empty, it willl save the file under "/users/$uid/". You can use
  /// this option to save the file under a different path.
  ///
  /// [compressQuality] is the quality of the compress for the image before uploading.
  ///
  /// [camera] is a flag to allow the user to choose the camera as the source.
  ///
  /// [gallery] is a flag to allow the user to choose the gallery as the source.
  ///
  /// [maxHeight] is the maximum height of the image to upload.
  ///
  /// [maxWidth] is the maximum width of the image to upload.
  ///
  /// It returns the download url of the uploaded file.
  Future<String?> upload({
    required BuildContext context,
    Function(double)? progress,
    Function()? complete,
    int compressQuality = 80,
    String? saveAs,
    bool camera = true,
    bool gallery = true,
    double maxHeight = 1024,
    double maxWidth = 1024,
  }) async {
    return uploadFrom(
      context: context,
      source: await chooseUploadSource(
        context: context,
        camera: true,
        gallery: true,
      ),
      progress: progress,
      complete: complete,
      compressQuality: compressQuality,
      saveAs: saveAs,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
    );
  }

  /// Upload a file (or an image) and save the url at the node in Realtime database.
  ///
  /// Logic
  /// 1. Upload
  /// 2. Save url at the path
  /// 3. Delete the previously existing image (if there is an old url in the path)
  ///
  /// [path] is the node to save the url.
  ///
  /// example:
  /// ```dart
  /// final url = await StorageService.instance.uploadAt(
  ///   context: context,
  ///   path: "${User.node}/${user.uid}/${Field.photoUrl}",
  ///   progress: (p) => setState(() => progress = p),
  ///   complete: () => setState(() => progress = null),
  /// );
  /// if (url != null) {
  ///   await my!.update(photoUrl: url);
  /// }
  /// ```
  Future<String?> uploadAt({
    required BuildContext context,
    required String path,
    Function(double)? progress,
    Function()? complete,
    int compressQuality = 80,
    String? saveAs,
    bool camera = true,
    bool gallery = true,
    double maxHeight = 1024,
    double maxWidth = 1024,
  }) async {
    String? url, oldUrl;
    oldUrl = await get<String?>(path);
    if (context.mounted) {
      url = await upload(
        context: context,
        progress: progress,
        complete: complete,
        compressQuality: compressQuality,
        saveAs: saveAs,
        camera: camera,
        gallery: gallery,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
      );
    }
    if (url == null) return null;

    // 업로드 성공
    await set(path, url);

    // 이전 파일 삭제
    if (oldUrl != null) {
      await delete(oldUrl);
    }

    return url;
  }

  /// Call this if method of uploading (like, from camera) is already known.
  ///
  /// [source] can be SourceType.photoGallery, SourceType.photoCamera,
  /// SourceType.videoGallery, SourceType.videoCamera, SourceType.file
  /// may return null if [source] is invalid.
  Future<String?> uploadFrom({
    required BuildContext context,
    required ImageSource? source,
    Function(double)? progress,
    Function? complete,
    int compressQuality = 80,
    String? saveAs,
    String? type,
    double maxHeight = 1024,
    double maxWidth = 1024,
  }) async {
    if (source == null) return null;
    String? path = await getFilePathFromPicker(
      context: context,
      source: source,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
    );
    if (path == null) return null;
    return await uploadFile(
      path: path,
      saveAs: saveAs,
      progress: progress,
      complete: complete,
      compressQuality: compressQuality,
      type: type,
    );
  }

  Future<String?> getFilePathFromPicker({
    required BuildContext context,
    required ImageSource? source,
    double maxHeight = 1024,
    double maxWidth = 1024,
  }) async {
    if (source == null) return null;

    try {
      if (source == ImageSource.camera) {
        final XFile? image = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxHeight: maxHeight,
          maxWidth: maxWidth,
        );
        return image?.path;
      } else if (source == ImageSource.gallery) {
        final XFile? image =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        return image?.path;
      }
      return null;
    } on PlatformException catch (error) {
      if (enableFilePickerExceptionHandler == false) rethrow;

      if (error.code == 'photo_access_denied') {
        errorToast(
          context: context,
          title: T.galleryAccessDeniedTitle.tr,
          message: T.galleryAccessDeniedContent.tr,
        );
      } else if (error.code == 'camera_access_denied') {
        errorToast(
          context: context,
          title: 'T.cameraAccessDeniedTitle.tr',
          message: 'T.cameraAccessDeniedContent.tr',
        );
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<List<String?>?> uploadMultiple({
    Function(double)? progress,
    Function? complete,
    int compressQuality = 80,
    String? type,
    double maxHeight = 1024,
    double maxWidth = 1024,
  }) async {
    final pickedFiles = await ImagePicker().pickMultiImage(
      imageQuality: 100,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
    );
    List<XFile> xFilePicks = pickedFiles;

    if (xFilePicks.isEmpty) return null;
    List<Future<String?>> uploads = [];
    for (XFile xFilePick in xFilePicks) {
      uploads.add(uploadFile(
        path: xFilePick.path,
        progress: progress,
        complete: complete,
        compressQuality: compressQuality,
        type: type,
      ));
    }
    return Future.wait(uploads);
  }

  /// 여러 이미지를 화면에 보여준다.
  ///
  showUploads(BuildContext context, List<String> urls, {int index = 0}) {
    if (customize.showUploads != null) {
      return customize.showUploads!(context, urls, index: index);
    }
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) =>
          DefaultImageCarouselScaffold(urls: urls, index: index),
    );
  }

  Future<List<String>> getAllImagesUrl(String uid) async {
    List<String> imageUrls = [];

    Reference storageRef =
        FirebaseStorage.instance.ref().child('users').child(uid);
    ListResult result = await storageRef.listAll();

    for (Reference ref in result.items) {
      String downloadUrl = await ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }
}

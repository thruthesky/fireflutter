import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  ///
  StorageService._();

  StorageCustomize customize = StorageCustomize();

  init({
    StorageCustomize? customize,
  }) {
    if (customize != null) {
      this.customize = customize;
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
    final fileRef = storageRef.child(saveAs ?? "users/${myUid!}/${file.path.split('/').last}");
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
        progress(event.bytesTransferred / event.totalBytes);
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
  Future<ImageSource?> chooseUploadSource(BuildContext context) async {
    return await showModalBottomSheet(
      context: context,
      builder: (_) => const DefaultUploadSelectionBottomSheet(),
    );
  }

  /// 사용자에게 사진/파일 업로드를 요청한다.
  ///
  /// 업로드가 완료되면, URL 을 리턴한다. 업로드가 취소되면, null 을 리턴한다.
  ///
  /// Ask user to upload a photo or a file
  ///
  /// Call this method when the user presses the button to upload a photo or a file.
  ///
  /// This method does not handle any exception. You may handle it outisde if you want.
  ///
  Future<String?> upload({
    required BuildContext context,
    Function(double)? progress,
    Function()? complete,
    int compressQuality = 80,
    String? path,
    String? saveAs,
    bool camera = true,
    bool gallery = true,
  }) async {
    return uploadFrom(
      source: await chooseUploadSource(context),
      progress: progress,
      complete: complete,
      compressQuality: compressQuality,
      path: path,
      saveAs: saveAs,
    );
  }

  /// Call this if method of uploading (like, from camera) is already known.
  ///
  /// [source] can be SourceType.photoGallery, SourceType.photoCamera,
  /// SourceType.videoGallery, SourceType.videoCamera, SourceType.file
  /// may return null if [source] is invalid.
  Future<String?> uploadFrom({
    required ImageSource? source,
    Function(double)? progress,
    Function? complete,
    int compressQuality = 80,
    String? path,
    String? saveAs,
    String? type,
  }) async {
    if (source == null) return null;
    String? path = await getFilePathFromPicker(source: source);
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
    required ImageSource? source,
  }) async {
    if (source == null) return null;

    if (source == ImageSource.camera) {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      return image?.path;
    } else if (source == ImageSource.gallery) {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      return image?.path;
    }
    return null;
  }

  Future<List<String?>?> uploadMultiple({
    Function(double)? progress,
    Function? complete,
    int compressQuality = 80,
    String? type,
  }) async {
    final pickedFiles =
        await ImagePicker().pickMultiImage(imageQuality: 100, maxHeight: 1000, maxWidth: 1000);
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
  /// TODO 확대를 할 수 있도록 해 준다.
  showUploads(BuildContext context, List<String> urls, {int index = 0}) {
    if (customize.showUploads != null) {
      return customize.showUploads!(context, urls, index: index);
    }
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => DefaultImageCarouselScaffold(urls: urls, index: index),
    );
  }
}

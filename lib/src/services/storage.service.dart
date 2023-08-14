import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  /// Currently login user's uid
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  ///
  StorageService._();

  /// Upload a file (or an image) to Firebase Storage.
  /// 범용 업로드 함수이며, 모든 곳에서 사용하면 된다.
  ///
  /// [file] is the file to upload.
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
  /// 이 값이 0 이면, compress 를 하지 않는다.
  Future<String?> upload({
    required File file,
    Function(double)? progress,
    Function? complete,
    int compressQuality = 80,
  }) async {
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef.child("easyuser/$uid/${file.path.split('/').last}");

    if (compressQuality > 0) {
      final xfile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${file.absolute.path}.compressed.jpg',
        quality: 80,
        // rotate: 180,
      );
      file = File(xfile!.path);
    }

    final uploadTask = fileRef.putFile(file);
    if (progress != null) {
      uploadTask.snapshotEvents.listen((event) {
        progress(event.bytesTransferred / event.totalBytes);
      });
    }

    /// 업로드 완료 할 때까지 기다림
    await uploadTask.whenComplete(() => complete?.call());
    final url = await fileRef.getDownloadURL();
    return url;
  }

  /// Delete the uploaded file in Firebase Storage by the url.
  ///
  /// If the url is null, it does nothing.
  Future<void> delete(String? url) async {
    if (url == null || url == '') return;
    final storageRef = FirebaseStorage.instance.refFromURL(url);
    await storageRef.delete();
    return;
  }
}

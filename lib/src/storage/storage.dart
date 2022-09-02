import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../fireflutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage Service
///
/// Refer readme file for details.
class Storage {
  static final String _uploadsPath = 'uploads';

  static final storage = FirebaseStorage.instance;
  static Reference get uploadsFolder => storage.ref().child(_uploadsPath);
  static Reference ref(String url) {
    return storage.refFromURL(url);
  }

  /// Available only for Android and iOS
  ///
  static Future<String> pickUpload({
    required ImageSource source,
    int quality = 90,
    Function(double)? onProgress,
    required String type,
  }) async {
    if (User.notSignedIn) throw ERROR_SIGN_IN_FIRST_FOR_FILE_UPLOAD;

    /// Pick image
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    /// No image picked. Throw error.
    if (pickedFile == null) throw ERROR_IMAGE_NOT_SELECTED;

    Uint8List file;

    if (!kIsWeb) {
      /// Compress image. Fix Exif data.
      File _file = await _imageCompressor(pickedFile.path, quality);
      file = _file.readAsBytesSync();
    } else {
      file = await pickedFile.readAsBytes();
    }

    return await upload(
      basename: pickedFile.name,
      file: file,
      onProgress: onProgress,
      type: type,
    );
  }

  /// Get [File] and return the uploaded url after upload.
  static Future<String> upload({
    required String basename,
    required Uint8List file,
    required String type,
    Function(double)? onProgress,
  }) async {
    if (User.notSignedIn) throw ERROR_SIGN_IN_FIRST_FOR_FILE_UPLOAD;

    /// Get generated filename.
    // final String basename = file.path.split('/').last;
    String extension = basename.split('.').last;
    if (extension == 'jpg') extension = 'jpeg';

    final filename = "${getRandomString()}.$extension";
    // print('filename; $filename');

    final ref = uploadsFolder.child(filename);

    /// Upload Task
    UploadTask uploadTask = ref.putData(
      file,
      SettableMetadata(customMetadata: {
        'basename': basename,
        'uid': User.uid!,
        'type': type,
      }),
    );

    /// Progress listener
    StreamSubscription? _sub;
    if (onProgress != null) {
      _sub = uploadTask.snapshotEvents.listen((event) {
        double progress = event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
        onProgress(progress);
      });
    }

    /// Wait for upload to finish.
    await uploadTask.whenComplete(() => _sub?.cancel());
    return ref.getDownloadURL();
  }

  /// Returns true if the file exists on storage. Or false.
  static Future<bool> exists(String url) async {
    if (url.startsWith('http')) {
      try {
        await ref(url).getDownloadURL();
        return true;
      } catch (e) {
        // debugPrint('getDownloadUrl(); $e');
        return false;
      }
    } else {
      return false;
    }
  }

  static Future<FullMetadata> getMetadata(String url) {
    return ref(url).getMetadata();
  }

  /// Delete uploaded file.
  ///
  /// If it's an image, then it will delete the thumbnail image.
  /// If it's not a file from firebase storage, it does not do anything.
  ///
  ///
  /// If it's an image url, then the [url] must be the original image url.
  /// If [url] does exist on storage, then it will not delete.
  ///
  /// Ignore object-not-found exception.
  ///
  /// If it throws [firestore_storage/unauthorized], then the user may try to delete file that does not belong him.
  /// This may happens in testing or putting url(photoUrl) of other user's photo.
  static Future<void> delete(String url) async {
    // final String thumbnailUrl = getThumbnailUrl(url);

    if (isFirebaseStorageUrl(url) == false) return;

    try {
      final re = await exists(url);
      if (re == false) return;
      await Future.wait(
        [
          ref(url).delete(),

          /// Delete thumbnail image if the uploaded file is an image in storage.
          if (isImageUrl(url) && await exists(getThumbnailUrl(url)))
            ref(getThumbnailUrl(url)).delete(),
        ],
      );
    } on FirebaseException catch (e) {
      // debugPrint('Exception happened on file delete; $e');
      if (e.code == 'object-not-found') {
        // debugPrint('object-not-found exception happened with: $url');
      } else {
        rethrow;
      }
    }
  }

  ///
  /// HELPER FUNCTIONS
  ///

  /// 파일을 압축하고, 가로/세로를 맞춘다.
  static _imageCompressor(String filepath, int quality) async {
    /// This method will be called when image was taken by [Api.takeUploadFile].
    /// It can compress the image and then return it as a File object.

    final String basename = filepath.split('/').last;

    /// 'c_' means, compressed.
    String localFile = await getAbsoluteTemporaryFilePath('c_' + basename);
    File? file = await FlutterImageCompress.compressAndGetFile(
      filepath, // source file
      localFile, // target file. Overwrite the source with compressed.
      quality: quality,
    );

    return file;
  }

  /// Returns thumbnail url.
  ///
  /// [url] is the original url and if the url is not an image from 'firebase storage', it will simply return the original url.
  /// Refer readme for details.
  ///
  /// ```dart
  /// Image.network(StorageService.instance.getThumbnailUrl(photo!.files[0]))
  /// ```
  static String getThumbnailUrl(String url) {
    if (url.contains('firebasestorage.googleapis.com') == false) {
      return url;
    }
    String _tempUrl = url;
    if (_tempUrl.indexOf('?') > 0) {
      _tempUrl = _tempUrl.split('?').first;
    }
    final String basename = _tempUrl.split('/').last;
    final String filename = basename.split('.').first;
    return _tempUrl.replaceFirst(basename, '${filename}_200x200.webp') + '?alt=media';
  }
}

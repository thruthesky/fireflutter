typedef Json = Map<String, dynamic>;

typedef ErrorCallback = Future<void> Function(dynamic e, StackTrace stackTrace);
typedef AlertCallback = Future<void> Function(String title, String content);
typedef ConfirmCallback = Future<bool> Function(String title, String content);
typedef ToastCallback = Future Function(String title, String message);

const ERROR_SIGN_IN_FIRST_FOR_FILE_UPLOAD = 'Please, sign in first before uploading.';
const ERROR_IMAGE_NOT_SELECTED = 'ERROR_IMAGE_NOT_SELECTED';

const COMMENT_CONTENT_DELETED = "Comment is deleted.";
const ERROR_ALREADY_DELETED = "Already deleted";
const ERROR_NO_PHOTO_ATTACHED = "Please, upload a photo.";

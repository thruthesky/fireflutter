typedef Json = Map<String, dynamic>;

typedef ErrorCallback = Future Function(dynamic message);
typedef AlertCallback = Future<bool?> Function(String title, String content);
typedef ConfirmCallback = Future<bool?> Function(String title, String content);
typedef SnackbarCallback = Function(
    {String? title, String? message, Function? onTap});
typedef VoidStringCallback = void Function(String);
typedef VoidNullableCallback = void Function()?;

enum UploadType { userProfilePhoto, user, post, comment, chat, party }

const ERROR_SIGN_IN_FIRST_FOR_FILE_UPLOAD =
    'Please, sign in first before uploading.';
const ERROR_SIGN_IN_FIRST_FOR_POST_CREATE =
    'Please, sign in first before creating a post.';
const ERROR_SIGN_IN_FIRST_FOR_COMMENT_CREATE =
    'Please, sign in first to create a comment';
const ERROR_IMAGE_NOT_SELECTED = 'ERROR_IMAGE_NOT_SELECTED';

const COMMENT_CONTENT_DELETED = "Comment is deleted.";
const ERROR_ALREADY_DELETED = "Already deleted";
const ERROR_NO_PHOTO_ATTACHED = "Please, upload a photo.";

const ERROR_NO_PROFILE_PHOTO = 'Please, input your profile photo.';
const ERROR_NO_EMAIL = 'Please, input email address.';
const ERROR_MALFORMED_EMAIL = 'Please, input correct email address.';
const ERROR_NO_FIRST_NAME = 'Please, input your first name.';
const ERROR_NO_LAST_NAME = 'Please, input your last name.';
const ERROR_NO_GENER = 'Please, select your gender.';
const ERROR_NO_BIRTHDAY = 'Please, select your birthday.';

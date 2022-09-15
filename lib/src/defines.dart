typedef Json = Map<String, dynamic>;

typedef ErrorCallback = Future Function(dynamic message);
typedef AlertCallback = Future<bool?> Function(String title, String content);
typedef ConfirmCallback = Future<bool?> Function(String title, String content);
typedef SnackbarCallback = Function(
    {String? title, String? message, Function? onTap});
typedef VoidStringCallback = void Function(String);
typedef VoidNullableCallback = void Function()?;

enum UploadType { userProfilePhoto, user, post, comment, chat, party }

enum ReportTarget { post, comment, user, chat }

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

const ERROR_POST_ALREADY_REPORTED = 'Post is already reported';
const ERROR_COMMENT_ALREADY_REPORTED = 'Comment is already reported';

const ERROR_SIGN_IN_FIRST_FOR_POST_REPORT =
    'Please, sign in first to report a post.';
const ERROR_SIGN_IN_FIRST_FOR_COMMENT_REPORT =
    'Please, sign in first to report a comment.';

const ERROR_CATEGORY_IS_EMPTY_ON_POST_CREATE =
    'Category is empty. (post-create/category-empty)';

const ERROR_POST_ID_IS_EMPTY_FOR_UPDATE = 'Post id is empty on update.';

const ERROR_NOT_YOUR_POST = 'Not your post';
const ERROR_NOT_YOUR_JOB_POST = 'Not your job post';

const ERROR_CATEGORY_IS_EMPTY_ON_CATEGORY_CREATE =
    'Please, input category ID to create the category';

const ERROR_CATEGORY_EXISTS_ON_CATEGORY_CREATE =
    'The category is already exists. Please, input another category ID.';

const ERROR_LACK_OF_POINT_ON_JOB_CREATE =
    'You don\'t have enough point to create a job post.';

const ERROR_SIGN_IN_FIRST_FOR_FORUM_CAETGORY_SUBSCRIPTION =
    "Please, sign-in first before subscribing a forum category.";

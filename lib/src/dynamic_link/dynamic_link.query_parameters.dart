// To prevent typing of Strings in query Parameters
/// Dynamic Link Query Parameters
class DynamicLinkQueryParameters {
  DynamicLinkQueryParameters({
    this.previewImageLink,
    this.previewText,
    this.appName,
    this.appIconLink,
    this.appleAppId,
    this.uid,
    this.category,
    this.postId,
    this.otherQueryParameters,
  });

  /// Preview Images
  String? previewImageLink;
  String? previewText;
  String? appName;
  String? appIconLink;
  String? appleAppId;
  String? uid;
  String? category;
  String? postId;
  Map<String, String>? otherQueryParameters;

  Map<String, String> toMap() => {
        if (previewImageLink != null) "previewImageLink": previewImageLink!,
        if (previewText != null) "previewText": previewText!,
        if (appName != null) "appName": appName!,
        if (appIconLink != null) "appIconLink": appIconLink!,
        if (appleAppId != null) "appleAppId": appleAppId!,
        if (uid != null) "uid": uid!,
        if (category != null) "category": category!,
        if (postId != null) "postId": postId!,
        ...?otherQueryParameters,
      };
}

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
    this.title,
    this.appStoreUrl,
    this.playStoreUrl,
    this.webUrl,
    this.otherQueryParameters,
  });

  /// Preview Images
  String? previewImageLink;

  /// The preview text
  String? previewText;

  /// The app's name
  /// This may be displayed as Title in the
  /// preview.
  String? appName;

  /// The app's icon
  /// This may be displayed as Icon in the
  /// preview.
  String? appIconLink;

  /// The app's AppId
  String? appleAppId;

  /// Value added to query parameter
  /// "uid"
  String? uid;

  /// Value added to query parameter
  /// "category"
  String? category;

  /// Value added to query parameter
  /// "postId"
  String? postId;

  /// The title that the user may see in the browser.
  String? title;

  /// If the iOS phone haven't installed the app,
  /// it may redirect to app store using this URL.
  String? appStoreUrl;

  /// If the Android phone haven't installed the app,
  /// it may redirect to play store using this URL.
  String? playStoreUrl;

  /// The webUrl can be used when the device is not detectable
  /// if it's an Android or an iOS. This will redirect to webUrl.
  String? webUrl;

  Map<String, String>? otherQueryParameters;

  // We can add the default values from Dynamic Link Service Instance if we have to.
  Map<String, String> toMap() => {
        if (previewImageLink != null) "previewImageLink": previewImageLink!,
        if (previewText != null) "previewText": previewText!,
        if (appName != null) "appName": appName!,
        if (appIconLink != null) "appIconLink": appIconLink!,
        if (appleAppId != null) "appleAppId": appleAppId!,
        if (uid != null) "uid": uid!,
        if (category != null) "category": category!,
        if (postId != null) "postId": postId!,
        if (title != null) "title": title!,
        if (appStoreUrl != null) "appStoreUrl": appStoreUrl!,
        if (playStoreUrl != null) "playStoreUrl": playStoreUrl!,
        if (webUrl != null) "webUrl": webUrl!,
        ...?otherQueryParameters,
      };
}

# Dynamic Link

Fireflutter provides a way to implement dynamic links using cloud function and Firebase Hosting. It will require to configure the manifest file for Android and Associated Domains for Apple.

## Configuration

### Android

In AndroidManifest.xml, add the following:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true" >
    <!-- Add this in activity -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <!-- Accepts URIs that begin with https://YOUR_HOST.COM -->
        <data
            android:scheme="https"
            android:host="YOUR_HOST.COM" />
    </intent-filter>
</activity>
```

Check out this [reference](https://developer.android.com/training/app-links) for more details on how to add this in Android app.

### Apple

Thru Xcode, add the Associated Domains in the Signing & Capabilities.

example:
applinks:YOUR_HOST

or update the runner entitlements file in ios folder.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
 <key>aps-environment</key>
 <string>development</string>
 <key>com.apple.developer.associated-domains</key>
 <array>
  <string>applinks:your-host.com</string>
 </array>
</dict>
</plist>
```

Check out this [reference](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app) for more details on how to add this in iOS app.

## Adding Deeplinks for Android or Custom URL Scheme for iOS

We are unsure about that the universial link and app link are not working in some circumstances like the link is opened in in-app-browswer. To make it work, the web (in cloud functino) tries to open the app using deeplink. The Kakaotalk app is the one that works this way. So, it is recommended to add deeplink in the app settins.



Check this [reference](https://developer.android.com/training/app-links/deep-linking) for Android.

Add this to the Android manifest file:

```xml
<intent-filter>
  ...
  <data android:scheme="https" android:host="www.example.com" />
  <data android:scheme="myappscheme" android:host="link" />
</intent-filter>
```

For iOS, check this [reference](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app).

To set it up, need to update it from Xcode.

From Xcode, there is an `Info` tab that goes along with `General -> Signing & Capabilitites -> Resource Tags`, etc.

Click `Info` tab. It will show a different screen that you can see the `URL types` section. You may need to scroll down a bit.

Press the "+" button then enter Identifier, Icon, **URL Schemes** (this is the one you need to set), and Role (Set this one as Viewer).

You can enter:

```text
Identifier: Custom Link
URL Scheme: myappscheme
Icon:
Role: Viewer
```

## Saving the Well Known Files

Well known files (assetlinks.json and apple-app-site-association), are used to validate app linking.

The values can be saved in Firestore collection, "\_link\_".

Be reminded to add the proper rules to access the collection in Firestore.

```rules
match /_deeplink_/{deeplink} {
    allow read: if true;
}
```

That will depend on how you made the rules.

### Android assetlinks.json

For android, in Firestore on the "\_link\_" collection, save it under document "android" using the app bundle id (as field name) and the array of sha 256 (as value):

For example:

com.com.appname: [
    "B2:9A:DC:EF:36:56:61:97:EB:AC:7A:BA:75:8C:EB:C7:BD:73:F7:D7:B0:6A:F2:E8:27:3D:DA:BD:B9:F4:8C:61"
]

### Apple apple-app-site-association

For apple, in Firestore on the "\_link\_" collection, save it under document "apple" using the team ID (as field name) and the app bundle id (as the value):

For example:

FII23432J: com.com.appname

### webUrl

Set the `webUrl` in Firestore on the "\_link\_" collection, using the field name `webUrl`, if you want to redirect it when device is not detected as Android or iOS.

### HTML

If the app is not installed in the an HTML will show in the browser. This can redirect to app store or play store depending on the device.

Set up the following:

1. appStoreUrl - This is the link to the appstore.
2. playStoreUrl - This is the link to the playstore.
3. urlScheme - This is the scheme used to open the app. This is for Custom URL Scheme (for iOS) and deep link (for Android).
4. html - You can provide your own custom HTML.

This is the default value of HTML:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta
      name="apple-itunes-app"
      content="app-id=#{{appleAppId}}, app-argument=#{{deepLinkUrl}}"
    />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="white" />
    <meta name="apple-mobile-web-app-title" content="#{{appName}}" />

    <link rel="icon" type="image/png" href="#{{appIconLink}}" />
    <link rel="mask-icon" href="" color="#ffffff" />
    <meta name="application-name" content="#{{appName}}" />

    <title>#{{appName}}</title>
    <meta name="description" content="#{{previewText}}" />

    <meta property="og:title" content="#{{appName}}" />
    <meta property="og:description" content="#{{previewText}}" />
    <meta property="og:image" content="#{{previewImageLink}}" />
    <meta property="og:type" content="website" />
    <meta property="og:locale" content="en_US" />

    <meta name="twitter:card" content="#{{previewText}}" />
    <meta name="twitter:title" content="#{{appName}}" />
    <meta name="twitter:site" content="#{{webUrl}}" />
    <meta name="twitter:description" content="#{{previewText}}" />
    <meta name="twitter:image" content="#{{previewImageLink}}" />
    <link rel="apple-touch-icon" href="#{{appIconLink}}" />
    <style>
      .centered {
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-family: Verdana, Geneva, Tahoma, sans-serif;
        color: white;
        font-size: x-large;
        text-align: center;
      }
      body {
        background-color: black;
      }
    </style>
  </head>
  <body>
    <div class="centered">
      Redirecting...
    </div>
    <script
      src="https://cdnjs.cloudflare.com/ajax/libs/Detect.js/2.2.2/detect.min.js"
      rossorigin="anonymous"
      referrerpolicy="no-referrer"
    ></script>
    <script>
      var result = detect.parse(navigator.userAgent);
      var deepLinkUrl = "#{{deepLinkUrl}}";
      var webUrl = "#{{webUrl}}";
      var appStoreUrl = "#{{appStoreUrl}}";
      var playStoreUrl = "#{{playStoreUrl}}";

      const stateTimer = setTimeout(function () {
        if (result.os.family === "iOS" && appStoreUrl.length > 0) {
          window.location.replace(appStoreUrl);
        } else if (
          result.os.family.includes("Android") &&
          playStoreUrl.length > 0
        ) {
          window.location.replace(playStoreUrl);
        } else {
          if (webUrl.length > 0) {
            window.location.replace(webUrl);
          }
        }
      }, 2000);
      window.addEventListener("visibiltychange", function () {
        clearTimeout(stateTimer);
        stateTimer = null;
        window.open("", "_self").close();
      });
      if (deepLinkUrl.length > 0) {
        location.href = deepLinkUrl;
      }
    </script>
  </body>
</html>
```

It will depend on your design if you want to put the links or redirection urls in the HTML and how to do it.

You can also add these in your HTML that will be replaced by the values in Firestore \_link\_ collection or the query parameters of the link.

1. #{{deepLinkUrl}}
This will be set depending on the value of `urlScheme` from link. For example, if the `urlScheme` is `myapp`, the deepLinkUrl will be `myapp://link`.

2. #{{webUrl}}
This will be replaced by `webUrl`.

3. "#{{appStoreUrl}}";
This will be replaced by `appStoreUrl`.

4. "#{{playStoreUrl}}";
This will be replaced by `playStoreUrl`.

5. #{{previewImageLink}}
This will come from the link's query `previewImageLink`.

6. #{{appName}}
This will come from the link's query `appName`.

7. #{{previewText}}
This will come from the link's query `previewText`.

8. #{{appIconLink}}
This will come from the link's query `appIconLink`.

9. #{{appleAppId}}
This will come from the link's query `appleAppId`.

10. #{{description}}
This will come from the link's query `description`.

11. #{{maskIconSvgUrl}}
This will come from the link's query `maskIconSvgUrl`.

## Applying the cloud function

To apply the cloud function, go to firebase/functions folder and run `npm run deploy:link`.

## Handle the links when user tapped it

To handle the links, you can use Fireflutter's `DynamicLinkService` class.

```dart
DynamicLinkService.instance.init(context: globalContext);
```

It will be best to initialize it when the context is ready.

By default, DynamicLinkService will handle links with "/post", and "/user" paths.

To add custom Dynamic links, must add the following code:

```dart
DynamicLinkService.instance.init(
    context: globalContext,
    onLink: (uri) {
        print("Your custom handler for dynamic link: $uri");
    },
);
```

You can also customize the path for posts and users.

```dart
DynamicLinkService.instance.init(
    context: globalContext,
    postPath: "/customPost",
    userPath: "/customUser",
);
```

## Creating a Dynamic Link

The `DynamicLinkService` has a functionality that allows us to make a link (for example, for sharing a content) in the app.

Example for creating link for post.

```dart
Future<void> onPressed() async {
  final Uri link = DynamicLinkService.instance.createPostLink(post!);
  Share.shareUri(link);
}
```

Example for creating link for user.

```dart
Future<void> onPressed() async {
  final Uri link = DynamicLinkService.instance.createUserLink(user!);
  Share.shareUri(link);
}
```

As noticed, `DynamicLinkService.instance.createPostLink()` and `DynamicLinkService.instance.createUserLink()` can be used to create links for posts and users.

## Custom Dynamic Links

Not all apps will have same functionalities and each app may require a number of dynamic link variations.

### Creating a Custom Dynamic Links

To create a custom dynamic link, you can use `DynamicLinkService.instance.createLink()` method.

```dart
  final Uri link = DynamicLinkService.instance.createLink(
    path = "/product",
    queryParameters = DynamicLinkQueryParameters(
      previewImageLink: "https://app.com/product-image-1",
      appName: "myAPP",
      appIconLink: "https://app.com/iconica",
      appleAppId: "APPLEAPPID",
      category: "fine-arts",
      otherQueryParameters: {
        "class": "A",
        "productId": "kksS1sS",
      }
    ),
  );
```

The [previewImageLink] will be the image to display on a preview.

The [appName] will be used to display the app name when the app is not installed. This is also used in the preview.

The [appIconLink] will be used to display the app's icon.

The [appleAppId] will be used for the Apple ID so that if the app is not installed, it may show a [smart app banner](https://developer.apple.com/documentation/webkit/promoting_apps_with_smart_app_banners).

The [otherQueryParameters] is a map that allows for other possible values in the query parameters that is not provided by DynamicLinkQueryParameters class.

The resulting link may look like this:

```html
https://yourapphost.com/product?previewImageLink=https%3A%2F%2Fapp.com/iconica&appName=myAPP&appleAppId=APPLEAPPID&category=fine-arts&class=A&productId=kksS1sS&appIconLink=https%3A%2F%2Fapp.com/product-image-1
```

### Handling the links when user tapped it

When the app handled the dynamic link, URI will be provided.

To open screen using uri:

```dart
DynamicLinkService.instance.showScreenFromUri(uri);
```

The example above is already sufficient if we already have the URI. However, in Fireflutter, we have to set it upon initialization so that we will handle it upon opening the app thru link.

Example Code:

```dart
  DynamicLinkService.instance.init(
    context: globalContext,
    host: "my-host.web.app",
    appName: "My Seller Store App",
    onLink: (uri) {
      // other than "/post" and "/user" onLink will be triggered.
      if (uri.path == "/test") {
        final productId = uri.queryParameters["productId"];
        final category = uri.queryParameters["category"];
        // TODO: add logic that will open the product screen based on your app.
      }
    },
  );
```

Be noted that if the link is for "/user" or "/post", `onLink` may not be triggered since it will be handled by Dynamic Link Service.

### Customize the path for user and post

To change the path for user or post you can also include the following:

```dart
  DynamicLinkService.instance.init(
    context: globalContext,
    host: "myownhost.web.app",
    appName: "Own Amazing App",
    postPath: "/customPostPath",
    userPath: "/customUserPath",
  );
```

Upon creating the links, this will also be used as paths for posts and users.

Based on the example, Dynamic Link Service will now handle links with "/customPostPath" and "/customUserPath" paths for posts and users respectively.

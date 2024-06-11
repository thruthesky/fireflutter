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

## Saving the Well Known Files

Well known files (assetlinks.json and apple-app-site-association), are used to validate app linking.

The values can be saved in Firestore collection, "\_link\_".

Be reminded to add the proper rules to access the collection in Firestore.

```rules
match /_link_/{link} {
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

For apple, in Firestore on the "\_link\_" collection, save it under document "apple". Save the TEAMID.bundleId as an array and save it in the field "apps":

For example under "ios" collection:

apps: [
  TEAMID.com.com.exampleapp
]

### webUrl

Set the `webUrl` in Firestore on the "\_link\_" collection, using the field name `webUrl`, if you want to redirect it when device is not detected as Android or iOS.

The path and query parameters will also be added to the web URL. Be careful that it may cause an infinite redirect loop if the link leads to the same place.

You can add some path value.

For example:

webUrl: https://example.com/redirection

If the link as `https://example.com/link?uid=1`, the resulting web URL will be `https://example.com/redirection/link?uid=1`.

### HTML

If the app is not installed in the an HTML will show in the browser. This can redirect to app store or play store depending on the device.

This is the default value of HTML:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <link rel="icon" type="image/png" href="#{{appIconLink}}" />

    <meta name="application-name" content="#{{appName}}" />

    <title>#{{title}}</title>
    <meta name="description" content="#{{description}}" />

    <meta property="og:title" content="#{{title}}" />
    <meta property="og:description" content="#{{description}}" />
    <meta property="og:image" content="#{{previewImageLink}}" />
    <meta property="og:type" content="website" />
    <meta property="og:locale" content="en_US" />

    <meta name="twitter:card" content="#{{description}}" />
    <meta name="twitter:title" content="#{{title}}" />
    <meta name="twitter:site" content="#{{webUrl}}" />
    <meta name="twitter:description" content="#{{description}}" />
    <meta name="twitter:image" content="#{{previewImageLink}}" />
    
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
      #{{redirectingMessage}}
    </div>
    <script
      src="https://cdnjs.cloudflare.com/ajax/libs/Detect.js/2.2.2/detect.min.js"
      rossorigin="anonymous"
      referrerpolicy="no-referrer"
    ></script>
    <script>
      var result = detect.parse(navigator.userAgent);
      var webUrl = "#{{webUrl}}";
      var appStoreUrl = "#{{appStoreUrl}}";
      var playStoreUrl = "#{{playStoreUrl}}";
      if (result.os.family === "iOS" && appStoreUrl.length > 0) {
        window.location.replace(appStoreUrl);
      } else if (
        result.os.family.includes("Android") &&
        playStoreUrl.length > 0
      ) {
        window.location.replace(playStoreUrl);
      } else if (webUrl.length > 0) {
          window.location.replace(webUrl);
      } else {
        alert("No url to redirect. Inform this to admin.");
      }
    </script>
  </body>
</html>
```

It will depend on your design if you want to put the links or redirection urls in the HTML and how to do it.

You can also add these in your HTML that will be replaced by the values in Firestore \_link\_ collection or the query parameters of the link.

1. #{{webUrl}}
This will be replaced by `webUrl`.

2. "#{{appStoreUrl}}";
This will be replaced by `appStoreUrl`.

3. "#{{playStoreUrl}}";
This will be replaced by `playStoreUrl`.

4. #{{previewImageLink}}
This will come from the link's query `previewImageLink`.

5. #{{appName}}
This will come from the link's query `appName`.

6. #{{previewText}}
This will come from the link's query `previewText`.

7. #{{appIconLink}}
This will come from the link's query `appIconLink`.

8. #{{appleAppId}}
This will come from the link's query `appleAppId`.

9. #{{description}}
This will come from the link's query `description`.

10. #{{redirectingMessage}}
This will come from the link's query `redirectingMessage`.

## Applying the cloud function

In `firebase.json` file, you can see this hosting set up:

```json
{
  // ...
  "hosting": {
    "public": "public",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "appAssociation": "NONE",
    "rewrites": [
      {
        "source": "/link{,/**}",
        "function": "link"
      },
      {
        "source": "/.well-known/**",
        "function": "link"
      }
    ]
  },
  // ...
}
```

The link function will be the function to be shown when the link matches the source.

To apply the cloud function, go to firebase/functions folder and run `npm run deploy:link`.

## Handle the links when user tapped it

To handle the links, you can use Fireflutter's `DynamicLinkService` class.

```dart
DynamicLinkService.instance.init(host: "myhost.com");
```

It will be best to initialize it when the context is ready.

By default, DynamicLinkService will handle links with "/post", and "/user" paths.

To add custom Dynamic links, must add the following code:

```dart
DynamicLinkService.instance.init(
  host: "myhost.com",
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
      appIconLink: "https://app.com/iconica.jpg",
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
https://yourapphost.com/product?previewImageLink=https%3A%2F%2Fapp.com/iconica&appName=myAPP&appleAppId=APPLEAPPID&category=fine-arts&class=A&productId=kksS1sS&appIconLink=https%3A%2F%2Fapp.com/iconica.jpg
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
    customUrlScheme: "deeplinkscheme",
    appStoreUrl: "https://applestorelink.com/id",
    playStoreUrl: "https://playstorelink.com/id",
    webUrl: "https://mywebsite.com/redirect",
  );
```

Upon creating the links, this will also be used as paths for posts and users.

Based on the example, Dynamic Link Service will now handle links with "/customPostPath" and "/customUserPath" paths for posts and users respectively.

### If App is not installed, route to stores

Include these upon initialization:

```dart
  DynamicLinkService.instance.init(
    context: globalContext,
    host: "myownhost.web.app",
    appName: "Own Amazing App",
    customUrlScheme: "deeplinkscheme",
    appStoreUrl: "https://applestorelink.com/id",
    playStoreUrl: "https://playstorelink.com/id",
    webUrl: "https://mywebsite.com/redirect",
  );
```

In case a user taps the link in a device which has not installed the app, `appStoreUrl`, `playStoreUrl` or `webUrl` will help to redirect the user from the browser.

For `customUrlScheme`, it may help when some apps (i.e. KakaoTalk) are using in-app browser that prevents the OS from opening your app when the link is tapped. It may open the app if deeplink (for Android) or custom URL scheme (for iOS) was set properly.

## ShareButton Widget

Fireflutter provides a default button for sharing post, user or others.

To use:

```dart
ShareButton(user: user)
```

You can also use the `ShareButton.textButton`.

```dart
ShareButton.textButton(post: post)
```

Or if you want a different content to share:

```dart
ShareButton(
  onTap: () {
    return DynamicLinkService.instance.createLink(path: "/ownPath");
  }
);
```

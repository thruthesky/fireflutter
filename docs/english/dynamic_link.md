# Dynamic Link

Fireflutter provides a way to implement dynamic links using cloud function and Firebase Hosting. It will require to configure the manifest file for Android and Associated Domains for Apple.

## Configuration

### Android

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

## Saving the Well Known Files

Well known files (assetlinks.json and apple-app-site-association), are used to validate app linking.

The values can be saved in Firestore collection, "\_deeplink\_".

### Android assetlinks.json

For android, save it under document "android" using the app bundle id (as field name) and the array of sha 256 (as value):

For example:

com.com.appname: [
    "B2:9A:DC:EF:36:56:61:97:EB:AC:7A:BA:75:8C:EB:C7:BD:73:F7:D7:B0:6A:F2:E8:27:3D:DA:BD:B9:F4:8C:61"
]

### Apple apple-app-site-association

For apple, save it under document "apple" using the team ID (as field name) and the app bundle id (as the value):

For example:

FII23432J: com.com.appname

## Applying the cloud function

To apply the cloud function, go to firebase/functions folder and run `npm run deploy:link`.

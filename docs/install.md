# Install

Follow the instruction below to install Fireship into your app

## 1. Install Fireship

### Install Fireship as a package

Simply add the latest version of fireship from pub.dev

### Install Fireship as a package developer

You may wish to develop your app while building(or updating) the Fireship package together.

- Fork the Fireship from `https://github.com/thruthesky/fireship`

- Then, clone it

- Then, create a branch in Fireship local repository

- Create `apps` folder under the root of Fireship folder and create your app inside `apps` folder.

```dart
mkdir apps
cd apps
flutter create your_project
```

- You need to add the path of the dependency as `../..`. Add the fireship dependency like below.

```yaml
dependencies:
  fireship:
    path: ../..
```

- If you have update any code in Fireship, consider to submit a `pull request`.

## 2. Install Firebase Database Secuirty

If you have your own firebase project, then you can use that. Or you can create one.

Refer to this reference: <https://firebase.google.com/docs/flutter/setup>

### Add the security rule for RTDB

<!-- TODO must have security rule -->

## Default app-environment entitlement

Add the following code into `info.plist`. These will be needed for access to camera and gallery.

```xml
<key>NSCameraUsageDescription</key>
<string>PhiLov app requires access to the camera to share the photo on profile, chat, forum.</string>
<key>NSMicrophoneUsageDescription</key>
<string>PhiLov app requires access to the microphone to share vioce with other users.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>PhiLov app requires access to the photo library to share the photo on profile, chat, forum.</string>
```

## Install Cloud Functions

Run the following command to install all the push notification cloud functions.

```sh
% cd firebase/function
% npm run deploy:message
```

And set the end point URL to `MessagingService.instance.init(sendPushNotificationsUrl: ..)`


Run the following command to install typesense related cloud functions.

```sh
% cd firebase/function
% npm run deploy:typesense
```


Run the following command to install a function that manages summarization of all posts under `/posts-all-summary`.
See the [Forum](forum.md) document for the details.

```sh
% cd firebase/function
% npm run deploy:managePostsAllSummary
```


## Setup the base code

<!-- TODO must add intallation guide -->

## Admin

- See [Admin Doc](admin.md)


## Unit tests

- There are many unit test codes. You can read other document of fireship on how to install and test the unit test codes.

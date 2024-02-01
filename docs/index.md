# Fireship

Fireship is a fast and powerful Flutter CMS library for real-time content management using Firebase Realtime Database.

## Installation

See [install.md](install.md)

## Database

Reference: [Database](database.md)

## User

Reference: [User Coding Manual](user.md)

## Sorting / Ordering

When sorting, the sorting field and value are stored in a separate node. For example, if you want to list users who uploaded photos in order of registration date or in the order they changed their profile pictures

- Database Structure Example
  - By doing the following, you can list users with profile pictures in the order they modified their photos.

`/user-profile-photos/<uid>/ { updatedAt: ..., photoUrl: ... }`

## Design Concept

### UI Design Customization

Fireship provides a default design that can be completely customized.

You may want to view a user's profile in various places in the app. For example, in a chat room, in a user list, or when clicking on a user's photo in a forum post/comment, you can show the user's public profile. In this case, by simply calling the `UserService.instance.showPublicProfile(uid: ...)` function uniformly, you can display the user's profile anywhere.

If you want to customize the design directly rather than using the default design, you can customize it by calling `UserSerivce.instance.init(customize: UserCustomize(...))`.

The names of customizable widgets start with `Default`. When customizing, you can simply copy and use the code from Fireship.

## Messaging

As the deprecation of [Send messages to multiple devices](https://firebase.google.com/docs/cloud-messaging/send-message#send-messages-to-multiple-devices) is stated in the [official Firebase Documentation](Send messages to multiple devices), we will send push notifications in Flutter code.

## Thumbnails

- Thumbnails are not used. In the past, thumbnail images were used through the Firebase Extensions Resize Image. However, since compression is applied when uploading images, the image size is not very large. Typically, when uploading images between 3MB and 5MB, they are reduced to 200KB to 300KB in size when uploaded to the client app.

## Admin

- Refer to [Admin Documentation](admin.md)

## TODO

- Refer to TODO document.
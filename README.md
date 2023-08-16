# FireFlutter

A free, open source, complete, rapid development package for creating Social apps, Chat apps, Community(Forum) apps, Shopping mall apps, and much more based on Firebase


## Features

* User management
* Chat
* Forum
* Push notification


## Getting started

If you want to build an app using FireFlutter, the best way is to copy codes from the example project.


### Setup

## Usage

### UserService

`UserService.instance.nullableUser` is null
- when the user didn't log in
- or when the user is logged in and has document, but the `UserService` has not read the user document, yet. In this case it simply needs to wait sometime.

`UserService.instance.nullableUser.exists` is false if the user has logged in but no document. In this case, the `documentNotExistBuilder` of `UserDoc` will be called.

So, the lifecyle will be the following when the app users `UserDoc`.
- `UserService.instance.nullableUser` will be null on app boot
- `UserService.instance.nullableUser` will have an instance of `User`
  - If the user document does not exists, `exists` will be `false` causing `documentNotExistsBuilder` to be called.
  - If the user document exsist, then it will have right data and `builder` will be called.




### Widgets

#### UserDoc


To display user's profile photo, use like below.

```dart
UserDoc(
  builder: (user) => UserProfileAvatar(
    user: user,
    size: 38,
    shadowBlurRadius: 0.0,
    onTap: () => context.push(ProfileScreen.routeName),
    defaultIcon: const FaIcon(FontAwesomeIcons.lightCircleUser, size: 38),
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  ),
  documentNotExistBuilder: () {
    UserService.instance.create();
    return const SizedBox.shrink();
  },
),
```

#### UserProfileAvatar


To display user's profile photo, use `UserProfileAvatar`.

```dart
UserProfileAvatar(
  user: user,
  size: 120,
),
```


#### UserProfileAvatar

To let user update or delete the profile photo, use like below.

```dart
UserProfileAvatar(
  user: user,
  size: 120,
  upload: true,
  delete: true,
),
```



## Translation

I feel like the standard i18n feature is a bit heavy and searched for other i18n packages. And I decided to write a simple i18n code for fireflutter.

The i18n code is in `lib/i18n/t.dart`.

By default, it supports English and you can change it to any language.

Here is an example of updating the translation.

```dart
tr.user.loginFirst = '로그인을 해 주세요.';
```



## Contribution

Fork the fireflutter and create your own branch. Then update code and push, then pull request.
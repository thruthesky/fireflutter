# User

Fireship includes basic functionalities for managing user information, so it's recommended to reuse its widgets or logic. Particularly, customizing the provided widgets by copying them is encouraged.

## User database structure

- User information is recorded in the `/users/<uid>` path of the realtime database.

`displayName` is the name of the user. FireFlutter, including all the widgets, will always use `displayName` to display the user's name. This can be either a real name or a nickname. If you want to store the user's name in a different format such as `firstName`, `middleName`, `lastName`, you can do so in your app. You may retrieve the user's real name and save it in the name field in your app.

`createdAt` indicates the time of the first login. This is the account creation time.

The user's real name or a name not displayed on the screen is stored in the `name` field. The displayed name is saved in the `displayName` field.

`isVerified` is a field that only administrators can modify. Even though it's included in the user document, users cannot modify it. Administrators manually verify identity documents and conduct video calls. Afterward, they can set `isVerified` to true.

`gender` can have values of `M` or `F` and may be null (no field). Note that the gender information can only be trusted when `isVerified` is true. In other words, if `isVerified` is not true, the gender information may not be true.

`blocks` stores a list of blocked users. Only users can perform blocking. Additionally, while users can perform actions like liking posts, comments, or chats, as well as bookmarking items such as posts, comments, etc., blocking is a one-sided action.

Regarding `likes`, it's essential for both parties to know who has liked whom. This necessitates a more complex data structure, hence the separate storage in `/user-likes`. However, with `blocks`, there's no need to inform others about whom a user has blocked. Therefore, it's stored directly in `/users`.

When values are stored in `latitude` and `longitude`, GeoHash strings of 4/5/6/7 characters are automatically saved in `geohash4`, `geohash5`, `geohash6`, and `geohash7`, respectively. This means that when using the Location or GeoLocator package in the app, setting permissions, obtaining Lat/Lon values, and saving them with `UserModel.update()`, GeoHash strings are automatically stored. For more details, refer to the section on [Distance Search](#distance-search).

## Customizing User UI

### Login Error UI

When attempting to access a page that requires login without logging in, `DefaultLoginFirstScreen` can be used. Here's how you can customize it:

```dart
UserService.instance.init(
  customize: UserCustomize(
    loginFirstScreen: const Text('Please login first!'),
  ...
  ),
)
```

`loginFirstScreen` is not a builder. Therefore, you can simply create a static widget, and if you wrap it in a Scaffold, it will work fine.

### User profile update screen

Fireflutter provides a few widgets to update user's profile information like below

#### DefaultProfileUpdateForm

`DefaultProfileUpdateForm` provides with the options below

- state image (profile background image)
- profile photo
- name
- state message
- birthday picker
- gender
- nationality selector
- region selector(for Korean nation only)
- job

`DefaultProfileUpdateForm` also provides more optoins.

You you can call `UserService.instance.showProfileScreen(context)` mehtod which shows the `DefaultProfileUpdateForm` as dialog.

It is important to know that Fireflutter uses `UserService.instance.showProfileScreen()` to display the login user's profile update screen. So, if you want to customize everything by yourself, you need to copy the code and make it your own widget. then conect it to `UserService.instance.init(customize: UserCustomize(showProfile: ... ))`.

#### SimpleProfileUpdateForm

This is very simple profile update form widget and we don't recommend it for you to use it. But this is good to learn how to write the user update form.

```dart
Scaffold(
  appBar: AppBar(
    title: const Text('Profile'),
  ),
  body: Padding(
    padding: const EdgeInsets.all(md),
    child: Theme(
      data: bigButtonTheme(context),
      child: SimpleProfileUpdateForm(
        onUpdate: () => toast(
          context: context,
          message: context.ke('업데이트되었습니다.', 'Profile updated.'),
        ),
      ),
    ),
  ),
);
```

## User Information Reference

You can use the UserDoc widget. For details, refer to the [widget documentation](#userdoc).

## Accessing My (Logged-in User's) Information

`UserService.instance.user` is a variable that holds the user document values from the database as a model. It is abbreviated as `my` for convenience. When the value in the database changes, the value of this variable is also updated (synchronized) in real-time. Therefore, after changing a value in the database, you can verify that the value is correctly stored in the `my` variable (after a short pause). For example, you can save form field values immediately upon change and then confirm them by pressing the submit button.

To reference the information of the logged-in user (yourself), you can use `MyDoc`. While using `UserDoc` is acceptable, using `MyDoc` is more effective.

In FireFlutter, whenever the data of the logged-in user changes, `UserService.instance.myDataChanges` automatically triggers the `myDataChanges` event, which is a BehaviorSubject. MyDoc widgets respond to this event, eliminating the need for additional DB access.

```dart
MyDoc(builder: (my) => Text("isAdmin: ${my?.isAdmin}"))
```

An example of displaying a widget if the user is an administrator:

```dart
MyDoc(builder: (my) => isAdmin ? Text('I am admin') : Text('I am not admin'))
```

If you are going to watch(listen) a value of a field, then you can use `MyDoc.field`.

```dart
MyDoc.field('${Field.blocks}/$uid', builder: (v) {
  return Text(v == null ? T.block.tr : T.unblock.tr);
})
```

### Displaying Admin Widgets

To check if a user is an administrator, you can simply do as follows:

```dart
Admin( builder: () => Text('I am an admin') );
```

## User Information Update

You can modify user information using `UserModel.update()`. However, the UserModel object holds the value before being stored in the database. Therefore, to use the updated value in the database, you can use `UserModel.reload()`.

```dart
await user.update(displayName: 'Banana');
await user.reload();
print(user.displayName);
```

## Displaying user data

- You can use `UserDoc` or `MyDoc` to display user data.
- The most commonly used user properties are name and photos. Fireflutter provides `UserDisplayName` and `UserAvatar` for your convinience.

### UserDoc

The `UserDoc` can be used like this:

```dart
UserDoc(
  uid: uid,
  builder: (data) {
    if (data == null) return const SizedBox.shrink();
    final user = UserModel.fromJson(data, uid: uid);
    return Text( user.displayName ?? 'No name' );
  },
),
```

### MyDoc

The `MyDoc` can be used like this:

```dart
MyDoc(
  builder: (my) {
    return Text( user.displayName ?? 'No name');
  }
),

```

### UserDisplayName

The `UserDisplayName` widget can be used like this:

```dart
UserDisplayName(uid: uid),
```

This will show `displayName`, not `name` of the user.

### UserAvatar

The `UserAvatar` widget can be used like this:

```dart
UserAvatar(uid: uid, size: 100, radius: 40),
```

## Block and unblock

You can block or unblock other user like below.

```dart
final re = await my?.block(chat.room.otherUserUid!);
```

You may want to let the user know if the other user has blocked or unblocked.

```dart
final re = await my?.block(chat.room.otherUserUid!);
toast(
  context: context,
  title: re == true ? 'Blocked' : 'Unblocked',
  message: re == true ? 'You have blocked this user' : 'You have unblocked this user',
);
```

## Widgets

### UpdateBirthdayField

Easily modify member birthdate information using the `UpdateBirthday` widget. You can use this widget to display birthday and let user to update his birthday in profile screen.

### UserTile

Use this widget to display the user information in a list.
`onTap` is optional and if it is not specified, the widget does not capture the tap event.

```dart
FirebaseDatabaseListView(
  query: Ref.users,
  itemBuilder: (_, snapshot) => UserTile(
    user: UserModel.fromSnapshot(snapshot),
    trailing: const Column(
      children: [
        FaIcon(FontAwesomeIcons.solidCheck),
        spaceXxs,
        Text('인증완료'),
      ],
    ),
    onTap: (user) {
      user.update(isVerified: true);
    },
  ),
),
```

You can use `trailing` to add your own buttons intead of using `onTap`.

### UserListView

Fireflutter provides a widget to display user list. We can use this if we don't have to customize the view.

```dart
UserListView()
```

## User likes

- User likes are saved under `/user-likes` and `/user-who-i-like`.
    - If A likes U, then A is saved under `/user-likes/U {A: true}` and U is saved under `/user-who-i-like/A { U: true}`.
- The fireflutter client code needs to save `/user-likes/U {A: true}` only. The cloud function `userLike` will take action and it will save the counter part `/user-who-i-like` data and update the `noOfLikes` on the user's node.

- The data structure will be like below.
    - When A like U,

```json
/user-likes/U { A: true }
/user-who-i-like/A { U: true }
/users/U {noOfLikes: 1}
```

- When A, B likes U,

```json
/user-likes/U { A: true, B: true}
/user-who-i-like/A {U: true}
/user-who-i-like/B {U: true}
/users/U {noOfLikes: 2}
```

- When B unlinke U,

```json
/user-likes/U { A: true }
/user-who-i-like/A { U: true }
/users/U {noOfLikes: 1}
```

- When A likes U, W

```json
/user-likes/U { A: true }
/user-likes/W { A: true }
/user-who-i-like/A { U: true, W: true }
/users/U {noOfLikes: 1}
/users/W {noOfLikes: 1}
```

You can use the `like` method to perform a like and unlike user like bellow.

```dart
IconButton(
  onPressed: () async {
     await my?.like(uid);
  },
  icon: const FaIcon(FontAwesomeIcons.heart),
),
```

## User Information Listening

`UserService.instance.myDataChanges` is executed once when `UserService.instance.init()` is called for the first time, and it triggers an event whenever the value of `/users/<my-uid>` is changed.

As it operates in a BehaviorSubject manner, the initial value may be null, and then the value is loaded from the realtime database shortly after. After that, it is called whenever the data value changes. Leveraging this feature, you can code appropriately based on changes in the logged-in user's information.

```dart
UserService.instance.myDataChanges.listen((user) {
  if (user == null) {
    print('User data is null. Not ready.');
  } else {
    print('User data is loaded. Ready. ${user.data}');
  }
});
```

If you want to take action only once when user data is loaded (or when the data changes), you can do the following:

```dart
StreamSubscription? listenRequiredField;
listenRequiredField = UserService.instance.myDataChanges.listen((user) {
  if (user != null) {
    checkUserData(user); // 프로필이 올바르지 않으면 새창을 띄우거나 등의 작업
    listenRequiredField?.cancel(); // 그리고 listenning 을 해제 해 버린다.
  }
});
```

### How to Require Users to Input a Photo or Name if They Haven't

You can check the value of `UserService.instance.myDataChanges` and if there is no name or photo, you can redirect them to a specific page.

```dart
class _HomeScreenState extends State<MainScreen> {
  StreamSubscription? subscribeMyData;

  @override
  void initState() {
    super.initState();

    subscribeMyData = UserService.instance.myDataChanges.listen((my) {
      if (my == null) return;
      // If the user is logged in but has no name or photo, redirect them to a screen where they can input the required fields.
      if (my.displayName.trim().isEmpty || my.photoUrl.isEmpty) {
        context.go(InputRequiredFieldScreen.routeName);
        // Cancel listening after executing once.
        subscribeMyData?.cancel();
      }
    });
  }
}
```

## Profile Editing Screen

The profile editing screen is a page where logged-in users can view and edit their own information. You can open the profile editing screen by calling `UserService.instance.showProfileScreen`.

## User Public Profile Screen

The user public profile screen is a page that can be viewed by every users.

The user profile screen can be displayed in various places. For example, when clicking on a user's name or icon in user lists, posts, comments, or chats, the user public profile screen opens. To make development easier, calling `UserService.instance.showPublicProfileScreen` triggers `DefaultPublicProfileScreen` to be displayed. If you want to customize the design, you can modify it in `UserService.instance.init(custom: ...)`. Customizing the design is recommended, and you can reuse small widgets used in the public profile.

Example - Customizing the public profile screen design through initialization.

```dart
UserService.instance.init(
  customize: UserCustomize(
    publicProfileScreen: (uid) => PublicProfileScreen(uid: uid),
  ),
);
```

By doing this, when the user taps on the profile picture, the `PublicProfileScreen` appears on the screen. You can either design this widget from scratch or it is recommended to copy and modify the `DefaultPublicProfileScreen`.

### Sending Push Notifications to the Other Member when Viewing User Profiles

Refer to the [Push Notification Message Documentation](messaging.md) for more information.

## Firestore Mirroring

Realtime Database lacks robust search functionality. Therefore, mirroring (backing up) user documents to Firestore allows for search capabilities using Firestore. This mirroring process can be achieved by installing a Cloud Function. Refer to the [installation documentation](install.md) for more information.

## Distance Search

For more detailed distance searches, applying a radius formula from SQL databases, Algolia, Typesense, etc., is necessary. However, with Firebase, conducting radius searches directly through the database dimension is not feasible, whether it's Realtime Database or Firestore.

If you really need radius search while using Firebase, you can:

1. Store location information in a third-party search engine like Algolia.
2. Store all user location information within the app (e.g., SQLite) and conduct radius searches internally.
3. Utilize Geohash values as explained in the official documentation: [Firestore GeoQueries](https://firebase.google.com/docs/firestore/solutions/geoqueries?hl=en). This involves fetching users with Geohash values corresponding to the desired range and then performing more accurate distance calculations within the app. However, this approach requires consideration of false positives, edge cases, and the cost of fetching unnecessary data.

Fireflutter provides a convenient method for distance search, although slightly different from the above three methods.

- Upon app startup, the user's latitude and longitude information are stored in the user document fields latitude and longitude.
    - Fireflutter then automatically stores geohash4, geohash5, geohash6, and geohash7.
    - Additionally, it can be mirrored in Firestore as needed.
- During searches, fetching users within 200 meters of the logged-in user simply involves retrieving users whose geohash7 matches that of the logged-in user in the database.
    - Geohash6 allows searches within 1 km, geohash5 within 5 km, and geohash4 within 20 km.

## Likes

When displaying as a text button, you can do it as follows. However, since the increase in the number of likes is handled by cloud functions, it may not be displayed in real-time, requiring appropriate handling.

```dart
ElevatedButton(
  onPressed: () async {
    await my?.like(uid);
  },
  child: Value(
    path: Path.userField(uid, Field.noOfLikes),
    builder: (v) => Text(
      v == null || v == 0
          ? T.like.tr
          : v == 1
              ? ('${T.like.tr} 1')
              : '${T.likes.tr} ${v ?? ''}',
    ),
  ),
),
```

## Likes List

There are two types of likes lists:

First, the list of people I liked.
Second, the list of people who liked me.

You can code as follows:


```dart
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({super.key});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Who Likes Me'),
              Tab(text: 'Who I Like'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WhoLikeMeListView(),
            WhoILikeListView(),
          ],
        ),
      ),
    );
  }
}
```

## Checking User Login and User Document Preparation

### AuthReady

`AuthReady` allows the builder callback function to be called and display widgets if the user is logged into Firebase. If the user is not logged in, the `notLogin` callback function is executed. Note that even if the user document in Firebase Realtime Database is not loaded, the builder function of this function is executed.

It is mainly used to check if the user UID is available after logging in to Firebase.

### MyDocReady

`MyDocReady` is used to check if the user document has been loaded from the Realtime Database after the user has logged into Firebase.

Internally, it simply uses the [MyDoc] widget to check if the user document has been loaded. If the user document has been loaded, it executes `builder(UserModel)` and if not, it displays [loading].

/// When using [MyDoc], builder(UserModel) may be null, so null check is necessary,
/// but [MyDocReady] is more convenient to use as builder(UserModel) is not null.

## Blocking

- Blocked users can be displayed as a list with `BlockListView`.
- If you want to display it as a string when blocked, you can use the `orBlock()` String extension.
- If you need to display it as a widget, use `Blocked`.

Example - When displaying pictures in the comment list, if the user is blocked, do not display the picture.

```dart
Blocked(
  uid: widget.comment.uid,
  yes: () => SizedBox.fromSize(),
  no: () => DisplayDatabasePhotos(
    urls: widget.comment.urls,
    path:
        '${Path.comment(widget.post.id, widget.comment.id)}/${Field.urls}',
  ),
),
```

Refer to the [widget documentation](widgets.md) for displaying the block button.

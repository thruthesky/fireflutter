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

You can use this widget to display birthday and let user to update his birthday in profile screen.

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










## Distance Search


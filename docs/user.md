# User

Much of the code is already included in Fireship.

For example, features like modifying user information or public profile pages are already in working codes. You can customize these UI elements.

## User database structure

- The user data is saved under `/users/<uid>`.

`displayName` is the name of the user.
Fireship (including all the widgets) will always use `dispalyName` to display the name of the user. This can be a real name, or it can be a nickname. If you want to keep user's name in different format like `firstName`, `middleName`, `lastName`, you can do it in your app. You may get user's real name and save it in `name` field in your app.


`createdAt` has the time of the first login. This is the account creation time.

사용자의 본명 또는 화면에 나타나지 않는 이름은 `name` 필드에 저장한다.
화면에 표시되는 이름은 `displayName` 필드에 저장을 한다. The user's real name or a name not displayed on the screen is stored in the name field. The displayed name is saved in the `displayName` field.

`isVerified` 는 관리자만 수정 할 수 있는 필드이다. 비록 사용자 문서에 들어 있어도 사용자가 수정 할 수 없다. 관리자가 직접 수동으로 회원 신분증을 확인하고 영상 통화를 한 다음 `isVerified` 에 true 를 지정하면 된다. `isVerified` is a field that only administrators can modify. Even if it's included in the user document, users cannot modify it. Administrators manually confirm identity documents and conduct video calls. Afterward, they can set `isVerified` to true.

`gender` 는 `M` 또는 `F` 의 값을 가질 수 있으며, null (필드가 없는 상태) 상태가 될 수도 있다. 참고로, `isVerified` 가 true 일 때에만 성별 여부를 믿을 수 있다. 즉, `isVerified` 가 true 가 아니면, `gender` 정보도 가짜일 수 있다. `gender` can have values of `M` or `F` and may be in a null state (no field). Note that the gender information can only be trusted when `isVerified` is true. In other words, if `isVerified` is not true, gender information may also be false.

- User profile photo is saved under `/users/<uid>` and `/user-profile-photos/<uid>`.
  - The reason why it saves the photo url into `/user-profile-photos` is to list the users who has profile photo.
    Without `/user-profile-photos` node, It can list with `/users` data but it cannot sort by time.
  - `/user-profile-photos/<uid>` has `updatedAt` field that is updated whenever the user changes profile photo.
  - It is managed by `UserModel`.

## 사용자 UI 커스터마이징 (Customizing User UI)

### 로그인 에러 UI (Login Error UI)

로그인이 필요한 상황에서 로그인을 하지 않고 해당 페이지를 이용하려고 한다면, `DefaultLoginFirstScreen` 이 사용된다. 이것은 아래와 같이 커스터마이징을 할 수 있다. If someone tries to access a page that requires login without logging in, `DefaultLoginFirstScreen` is used. You can customize it as follows:

```dart
UserService.instance.init(
  customize: UserCustomize(
    loginFirstScreen: const Text('로그인을 먼저 해 주세요. (Please login first!)'),
  ...
  ),
)
```

`loginFirstScreen` 은 builder 가 아니다. 그래서 정적 widget 을 만들어주면 되는데, Scaffold 를 통째로 만들어 넣으면 된다. `loginFirstScreen` is not a builder. So, you can create a static widget, and if you put it in a Scaffold, it will work.

### 회원 정보 수정 페이지 (User Profile Editing Page)

기본적으로 `DefaultProfileScreen` 이 사용되는데, 커스터마이징을 할 수 있다 (By default, `DefaultProfileScreen` is used, but it can be customized).

## Access to other user data

You can use `UserDoc` to access other user's data. Note that you can use it to get your data also.

`UserDoc` caches the data in memory by default. This mean, it will get the data only once from Database. You may use `cache` option with false to get the data from the Database again.

```dart
UserDoc(
  uid: uid,
  builder: (data) {
    if (data == null) return const SizedBox.shrink();
    final user = UserModel.fromJson(data, uid: uid);
    return Column(
      children: [
        Text(
          user.displayName ?? 'No name',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        if (user.stateMessage != null)
          Text(
            user.stateMessage!,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Colors.white.withAlpha(200),
                ),
          ),
      ],
    );
  },
),
```

It's important to know that you can use `field` property to get only the value of the field. It's recommended to use `field` whenever possible since the size of user data may be large.

You can use `sync` method to update (rebuild) the widget whenever the value changes.

```dart
UserDoc.sync(uid: user.uid, field: 'displayName', builder: (data, $) => Text(data)),
```

## 나의 (로그인 사용자) 정보 액세스 Accessing My (Logged-in User) Information

로그인한 사용자(나)의 정보를 참조하기 위해서는 `MyDoc` 를 사용하면 된다. 물론, `UserDoc` 를 사용해도 되지만, `MyDoc` 를 사용하는 것이 더 효과적이다. To reference the information of the logged-in user (yourself), you can use MyDoc. While using UserDoc is acceptable, using MyDoc is more effective.

Fireship 은 `UserService.instance.myDataChanges` 를 통해서 로그인 한 사용자의 데이터가 변경 될 때 마다, 자동으로 BehaviorSubject 인 `myDataChanges` 이벤트 시키는데 그 이벤트를 받아서 `MyDoc` 위젯이 동작한다. 그래서 추가적으로 DB 액세스를 하지 않아도 되는 것이다. Fireship uses UserService.instance.myDataChanges to automatically trigger the BehaviorSubject myDataChanges event whenever the data of the logged-in user changes. MyDoc widgets respond to this event, eliminating the need for additional DB access.

```dart
MyDoc(builder: (my) => Text("isAdmin: ${my?.isAdmin}"))
```

관리자이면 위젯을 표시하는 예. An example of displaying a widget if the user is an administrator:

```dart
MyDoc(builder: (my) => isAdmin ? Text('I am admin') : Text('I am not admin'))
```

If you are going to watch(listen) a value of a field, then you can use `MyDoc.field`.

```dart
MyDoc.field('${Field.blocks}/$uid', builder: (v) {
  return Text(v == null ? T.block.tr : T.unblock.tr);
})
```

### 관리자 위젯 표시 (Displaying Admin Widgets)

관리자 인지 확인하기 위해서는 아래와 같이 간단하게 하면 된다. To check if a user is an administrator, you can do it as follows:

```dart
Admin( builder: () => Text('I am an admin') );
```

## 사용자 정보 수정 (User Information Update)

`UserModel.update()` 를 통해서 사용자 정보를 수정 할 수 있다. 그러나 UserModel 의 객체는 DB 에 저장되기 전의 값을 가지고 있다. 그래서, DB 에 업데이트 된 값을 쓰기 위해서는 `UserModel.reload()` 를 쓰면 된다.

```dart
await user.update(displayName: 'Banana');
await user.reload();
print(user.displayName);
```

## Displaying user data

- You can use `UserDoc` or `MyDoc` to display user data.
- The most commonly used user properties are name and photos. Fireship provides `UserDisplayName` and `UserAvatar` for your convinience.

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

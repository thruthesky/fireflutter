# 사용자

사용자 정보 관리에 필요한 기본 기능이 fireship 에 포함되어져 있으므로 그 위젯이나 로직을 재 활용하면 좋다. 특히, 기본 제공되는 위젯을 복사해서 커스텀해서 사용하는 것을 권장한다.


## User database structure

- 사용자 정보는 realtime database 의 `/users/<uid>` 에 기록된다.


`displayName` is the name of the user.
Fireship (including all the widgets) will always use `dispalyName` to display the name of the user. This can be a real name, or it can be a nickname. If you want to keep user's name in different format like `firstName`, `middleName`, `lastName`, you can do it in your app. You may get user's real name and save it in `name` field in your app.

`createdAt` has the time of the first login. This is the account creation time.

사용자의 본명 또는 화면에 나타나지 않는 이름은 `name` 필드에 저장한다.
화면에 표시되는 이름은 `displayName` 필드에 저장을 한다. The user's real name or a name not displayed on the screen is stored in the name field. The displayed name is saved in the `displayName` field.

`isVerified` 는 관리자만 수정 할 수 있는 필드이다. 비록 사용자 문서에 들어 있어도 사용자가 수정 할 수 없다. 관리자가 직접 수동으로 회원 신분증을 확인하고 영상 통화를 한 다음 `isVerified` 에 true 를 지정하면 된다. `isVerified` is a field that only administrators can modify. Even if it's included in the user document, users cannot modify it. Administrators manually confirm identity documents and conduct video calls. Afterward, they can set `isVerified` to true.

`gender` 는 `M` 또는 `F` 의 값을 가질 수 있으며, null (필드가 없는 상태) 상태가 될 수도 있다. 참고로, `isVerified` 가 true 일 때에만 성별 여부를 믿을 수 있다. 즉, `isVerified` 가 true 가 아니면, `gender` 정보도 가짜일 수 있다. `gender` can have values of `M` or `F` and may be in a null state (no field). Note that the gender information can only be trusted when `isVerified` is true. In other words, if `isVerified` is not true, gender information may also be false.

`blocks` 는 차단한 사용자의 목록을 가지고 있다. 차단은 사용자만 할 수 있다.
참고로, 좋아요는 사용자, 글, 코멘트, 채팅 등에 할 수 있고, 북마크는 사용자, 글, 코멘트 등에 할 수 있으나, 차단은 사용만 할 수 있다.
참고로, `likes` 는 쌍방으로 정보 확인이 가능해야한다. 이 말은 내가 누구를 좋아요 했는지 알아야 할 필요가 있고, 상대방도 내가 좋아요를 했는지 알아야 할 필요가 있다. 그래서 데이터 구조가 복잡해 `/user-likes` 에 따로 저장을 하지만, `blocks` 는 내가 누구를 차단했는지 다른 사람에게 알려 줄 필요가 없다. 그래서 `/users` 에 저장을 한다.


`latitude` 와 `longitude` 에 값이 저장되면 자동으로 `geohash4`, `geohash5`, `geohash6`, `geohash7` 에 GeoHash 문자열 4/5/6/7 자리 값이 저장된다. 즉, 위/경도의 값은 앱에서 Location 또는 GeoLocator 패키지를 써서, 퍼미션 설정을 하고, Lat/Lon 값을 구한 다음, `UserModel.update()` 로 저장하면, 자동으로 geohash 문자열이 저장되는 것이다. 보다 자세한 내용은 [거리 검색](#거리-검색)을 참고한다.





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

### User profile update screen

Fireship provides a few widgets to update user's profile information like below

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


You you can call `UserService.instance.showProfile(context)` mehtod which shows the `DefaultProfileUpdateForm` as dialog.

It is important to know that fireship uses `UserService.instance.showProfile()` to display the login user's profile update screen. So, if you want to customize everything by yourself, you need to copy the code and make it your own widget. then conect it to `UserService.instance.init(customize: UserCustomize(showProfile: ... ))`.


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


## 사용자 정보 참고

`UserDoc` 위젯을 사용 하면 된다. 자세한 것은, 위젯 문서를 참고한다.



## 나의 (로그인 사용자) 정보 액세스

`UserService.instance.user` 는 DB 의 사용자 문서 값을 모델로 가지고 있는 변수이다. 짧게 `my` 로 쓸 수 있도록 해 놓았다. DB 의 값이 변경되면 실시간으로 이 변수의 값도 업데이트(sync)된다. 그래서 DB 에 값을 변경 한 다음, (약간 쉬었다) `my` 변수로 올바로 값이 저장되었는지 확인 할 수 있다. 예를 들면, form field 값 변경 즉시 저장하고, submit 버튼을 누르면 확인을 할 수 있다.






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

### UserListView

Fireship provides a widget to display user list. We can use this if we don't have to customize the view.

```dart
UserListView()
```


## User likes


- User likes are saved under `/user-likes` and `/user-who-i-like`.
  - If A likes U, then A is saved under `/user-likes/U {A: true}` and U is saved under `/user-who-i-like/A { U: true}`.
- The fireship client code needs to save `/user-likes/U {A: true}` only. The cloud function `userLike` will take action and it will save the counter part `/user-who-i-like` data and update the `noOfLikes` on the user's node.

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


## 사용자 정보 listening

`UserService.instance.myDataChanges` 는 `UserService.instance.init()` 이 호출 될 때, 최초로 한번 실행되고, `/users/<my-uid>` 의 값이 변경 될 때마다 이벤트를 발생시킨다.

BehaviourSubject 방식으로 동작하므로, 최초 값이 null 일 수 있으며, 그 이후 곧 바로 realtime database 에서 값이 한번 로드된다. 그리고 난 다음에는 data 값이 변경 될 때 마다 호출된다. 이러한 특성을 살려 로그인한 사용자 정보의 변화에 따라 적절한 코딩을 할 수 있다.

```dart
UserService.instance.myDataChanges.listen((user) {
  if (user == null) {
    print('User data is null. Not ready.');
  } else {
    print('User data is loaded. Ready. ${user.data}');
  }
});
```


만약, 사용자 데이터가 로딩될 때 (또는 데이터가 변하는 경우), 한번만 어떤 액션을 취하고 싶다면, 아래와 같이 하면 된다.

```dart
StreamSubscription? listenRequiredField;
listenRequiredField = UserService.instance.myDataChanges.listen((user) {
  if (user != null) {
    checkUserData(user); // 프로필이 올바르지 않으면 새창을 띄우거나 등의 작업
    listenRequiredField?.cancel(); // 그리고 listenning 을 해제 해 버린다.
  }
});
```


### 사용자가 사진 또는 이름을 입력하지 않았으면 강제로 입력하게하는 방법

아래와 같이, `UserService.instance.myDataChanges` 의 값을 살펴보고, 이름 또는 사진이 없으면 특정 페이지로 이동하게 하면 된다.

```dart
class _HomeScreenState extends State<MainScreen> {
  StreamSubscription? subscribeMyData;

  @override
  void initState() {
    super.initState();

    subscribeMyData = UserService.instance.myDataChanges.listen((my) {
      if (my == null) return;
      // 로그인을 한 다음, 이름이나 사진이 없으면, 강제로 입력 할 수 있는 스크린으로 이동해 버린다.
      if (my.displayName.trim().isEmpty || my.photoUrl.isEmpty) {
        context.go(InputRequiredFieldScreen.routeName);
        // 한번만 listen 하도록 한다.
        subscribeMyData?.cancel();
      }
    });
```


## 회원 정보 수정 화면

회원 정보 수정 화면은 로그인 한 사용자가 본인의 정보를 보는 페이지다. `UserService.instance.showProfileScreen` 을 호출하면 회원 정보 수정 화면을 열 수 있다.



## 사용자 공개 프로필 화면

사용자 공개 프로필 화면은 본인 뿐만아니라 다른 사용자가 보는 페이지이다.

사용자 프로필 화면은 여러 곳에서 보여질 수 있다. 예를 들면, 사용자 목록, 게시판, 코멘트, 채팅 등등에서 사용자 이름이나 아이콘을 클릭하면 사용자 공개 프로필 화면이 열리는 것이다. 그래서, 개발하기 편하게 하기 위해서 `UserService.instance.showPublicProfileScreen` 을 호출하면, `DefaultPublicProfileScreen` 이 호출 되도록 했다. 커스텀 디자인을 하려면 `UserService.instance.init(custom: ...)` 에서 수정하면 된다. 사실 커스텀 디자인을 추천하며, 공개 프로필에 들어가는 각각의 작은 위젯들을 재 활용하면 된다.



예제 - 초기화

```dart
UserService.instance.init(
  customize: UserCustomize(
    publicProfileScreen: (uid) => PublicProfileScreen(uid: uid),
  ),
);
```


예제 - PublicProfileScreen

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class PublicProfileScreen extends StatelessWidget {
  static const String routeName = '/PublicProfile';
  const PublicProfileScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: UserDoc.field(
            uid: uid,
            field: Field.profileBackgroundImageUrl,
            builder: (url) => CachedNetworkImage(
              imageUrl: url ?? 'https://picsum.photos/id/171/400/900',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: const Align(child: Text("PublicProfile"))),
      ],
    );
  }
}
```





## 위젯

`UpdateBirthday` 위젯을 통해서 손 쉽게 회원 생년월일 정보를 수정 할 수 있다. 위젯 문서 참고


## Firestore 미러링

Realtime Database 는 검색 기능이 매우 부족하다. 그래서 사용자 문서를 Firestore 로 미러링(백업)을 해서, Firestore 를 통해서 검색 할 수 있다. 이 미러링 작업은 Cloud function 을 설치하면 된다. 참고, [설치 문서](./install.md).




## 거리 검색

거리를 검색 할 때 보다 상세한 검색을 하려면, SQL 데이터베이스, Algolia, Typesense 등의 Radius 수식을 적용하여 검색해야 한다. 그러나 Firebase 에서는 Realtime Database 나 Firestore 에서는 DB 차원을 통해서 Radius 검색을 할 수 없다.

Firebase 를 사용하면서, Radius 검색을 꼭 해야겠다면
1. Location 정보를 Algolia 와 같은 3rd party 검색 엔진에 저장을 하던지
2. 또는 사용자의 모든 Location 정보를 앱 내(SQLite 등)에 보관해 놓고, Radius 검색을 할 수 있다.
3. 또는 공식문서: [Firebase 지역 쿼리](https://firebase.google.com/docs/firestore/solutions/geoqueries?hl=ko)에서 설명하듯이 Geohash 네자리 수에 해당하는 값을 가진 사용자를 가져와 앱 내에서 보다 정확하게 distance 계산을 하는 것이다. 하지만, 이와 같은 경우 `거짓양성`, `에지케이스`, `필요없는 데이터를 가져오는 비용`을 고려해야 한다.

Fireship 에서 기본 제공하는 거리 검색은 위의 세 가지 방법과는 조금 다르지만 매우 편리한 방법이다.

- 먼저 앱이 실행되면 사용자의 위/경도 정보를 사용자 문서 필드  `latitude`, `longitude` 에 저장한다.
  - 그러면 fireship 이 자동으로 geohash4,geohash5,geohash6,geohash7 를 저장한다.
  - 그리고, 필요에 따라 Firestore 미러링되게 한다.

- 검색을 할 때, 로그인한 사용자의 200 미터 내의 사용자 검색은 로그인을 한 사용자의 geohash7 과 DB 의 geohash7 이 일치하는 사용자를 가져와 보여주면 된다.
  - geohash6 는 1km 이내, geohash5 는 5km 이내, geohash4 는 20km 이내의 사용자를 검색 할 수 있다.








## 좋아요


텍스트 버튼으로 표시 할 때 아래와 같이 할 수 있다. 다만, 좋아요 숫자 증가는 cloud function 에 의해서 동작하므로, 실시간으로 빠르게 표시되 않는데, 적절한 처리가 필요하다.

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


### 좋아요 목록

좋아요 목록은 두가지가 있다.
- 첫째, 내가 좋아요 한 사람 목록.
- 둘째, 나를 좋아요 한 사람 목록.


아래와 같이 코딩을 하면 된다.

```dart
//..
```



## 블럭


- 블럭된 사용자는 `BlockListView` 로 목록으로 표시 할 수 있다.
- 블럭된 경우 문자열로 표시하는 경우는 `orBlock()` String extension 을 사용하면 된다.
- 위젯으로 표시를 해야하는 경우는 `Blocked`로 하면 된다.




예제 - 코멘트 목록에서 사진을 표시할 때, 사용자가 차단되어져 있으면 사진을 표시하지 않는다.

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




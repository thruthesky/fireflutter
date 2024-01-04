# 사용자

많은 부분의 코드가 이미 fireship 내에 들어가 있다.

예를 들면, 회원 정보 수정이나, 공개 프로필 페이지 등은 바로 동작을 하는 상태이다. 이러한 UI 는 customize 할 수 있다.


## 사용자 데이터베이스


사용자의 본명 또는 화면에 나타나지 않는 이름은 `name` 필드에 저장한다.
화면에 표시되는 이름은 `displayName` 필드에 저장을 한다.


`isVerified` 는 관리자만 수정 할 수 있는 필드이다. 비록 사용자 문서에 들어 있어도 사용자가 수정 할 수 없다. 관리자가 직접 수동으로 회원 신분증을 확인하고 영상 통화를 한 다음 `isVerified` 에 true 를 지정하면 된다.

`gender` 는 `M` 또는 `F` 의 값을 가질 수 있으며, null (필드가 없는 상태) 상태가 될 수도 있다. 참고로, `isVerified` 가 true 일 때에만 성별 여부를 믿을 수 있다. 즉, `isVerified` 가 true 가 아니면, `gender` 정보도 가짜일 수 있다.


## 사용자 UI 커스터마이징


### 로그인 에러 UI

로그인이 필요한 상황에서 로그인을 하지 않고 해당 페이지를 이용하려고 한다면, `DefaultLoginFirstScreen` 이 사용된다. 이것은 아래와 같이 커스터마이징을 할 수 있다.

```dart
UserService.instance.init(
  customize: UserCustomize(
    loginFirstScreen: const Text('로그인을 먼저 해 주세요.'),
```

`loginFirstScreen` 은 builder 가 아니다. 그래서 정적 widget 을 만들어주면 되는데, Scaffold 를 통째로 만들어 넣으면 된다.



### 회원 정보 수정 페이지


기본적으로 `DefaultProfileScreen` 이 사용되는데, 커스터마이징을 할 수 있다.





## 사용자 정보 액세스

`UserDoc` 을 통해서 다른 사용자의 정보를 가져 올 수 있다. 물론 자기 자신의 정보도 가져 올 수 있다.

기본적으로 데이터를 한 번만 가져와서 내부적으로 캐시를 한다. 즉, 한번 데이터를 가져오면, 두번 가져오지 않는다. 그래서 사용자의 데이터가 변경되어도 이전값을 보여 줄 수 있다. `cache` 옵션을 false 로 주면, 위젯을 빌드 할 때 마다 데이터를 가져온다.

```dart
UserDoc(
  uid: message.uid!,
  field: null,
  builder: (data) => UserAvatar(
    user: user,
    radius: 13,
    onTap: () => ...,
  ),
),
```



만약, 다른 회원의 정보가 변경 될 때 위젯이 자동으로 rebuild 되도록 하려면, `UserDoc.sync` 를 사용하면 된다.

```dart
UserDoc.sync(uid: user.uid, field: 'displayName', builder: (data, $) => Text(data)),
```



## 나의 (로그인 사용자) 정보 액세스


로그인한 사용자(나)의 정보를 참조하기 위해서는 `MyDoc` 를 사용하면 된다. 물론, `UserDoc` 를 사용해도 되지만, `MyDoc` 를 사용하는 것이 더 효과적이다.

Fireship 은 `UserService.instance.myDataChanges` 를 통해서 로그인 한 사용자의 데이터가 변경 될 때 마다, 자동으로 BehaviorSubject 인 `myDataChanges` 이벤트 시키는데 그 이벤트를 받아서 `MyDoc` 위젯이 동작한다. 그래서 추가적으로 DB 액세스를 하지 않아도 되는 것이다.

```dart
MyDoc(builder: (my) => Text("isAdmin: ${my?.isAdmin}"))
```

관리자이면 위젯을 표시하는 예
```dart
MyDoc(builder: (my) => isAdmin ? Text('I am admin') : Text('I am not admin')
```

### 관리자 위젯 표시

관리자 인지 확인하기 위해서는 아래와 같이 간단하게 하면 된다.

```dart
Admin( builder: () => Text('I am an admin') );
```



## 사용자 정보 수정

`UserModel.update()` 를 통해서 사용자 정보를 수정 할 수 있다. 그러나 UserModel 의 객체는 DB 에 저장되기 전의 값을 가지고 있다. 그래서, DB 에 업데이트 된 값을 쓰기 위해서는 `UserModel.reload()` 를 쓰면 된다.


```dart
await user.update(displayName: 'Banana');
await user.reload();
print(user.displayName);
```



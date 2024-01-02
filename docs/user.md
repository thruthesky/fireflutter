# 사용자

많은 부분의 코드가 이미 fireship 내에 들어가 있다.

예를 들면, 회원 정보 수정이나, 공개 프로필 페이지 등은 바로 동작을 하는 상태이다. 이러한 UI 는 customize 할 수 있다.


## 사용자 데이터베이스


사용자의 본명 또는 화면에 나타나지 않는 이름은 `name` 필드에 저장한다.
화면에 표시되는 이름은 `displayName` 필드에 저장을 한다.



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

아래의 예제는 사용자 이름을 실시간으로 표시한다.
```dart
UserData.sync(uid: user.uid, field: 'displayName', builder: (data, $) => Text(data)),
```

아래는 DB 로 부터 한번만 가져온다. 내부적으로 캐시를 한다.
```dart
UserData(
  uid: message.uid!,
  field: null,
  builder: (data) => UserAvatar(
    user: user,
    radius: 13,
    onTap: () => ...,
  ),
),
```


## 나의 (로그인 사용자) 정보 액세스


로그인한 사용자(나)의 정보를 참조하기 위해서는 `MyDataChanges` 를 사용하면 된다. 물론, `UserData` 를 사용해도 되지만, `MyDataChanges` 를 사용하는 것이 더 효과적이다.

Fireship 은 `UserService.instance.myDataChanges` 를 통해서 로그인 한 사용자의 데이터가 변경 될 때 마다, 자동으로 `myDataChanges` 이벤트 시키는데 그 이벤트를 받아서 `MyDataChanges` 위젯이 동작한다. 그래서 추가적으로 DB 액세스를 하지 않아도 되는 것이다.


```dart
MyDataChanges(builder: (my) => Text("isAdmin: ${my?.isAdmin}"))
```



## 사용자 정보 수정

`UserModel.update()` 를 통해서 사용자 정보를 수정 할 수 있다. 그러나 UserModel 의 객체는 DB 에 저장되기 전의 값을 가지고 있다. 그래서, DB 에 업데이트 된 값을 쓰기 위해서는 `UserModel.reload()` 를 쓰면 된다.


```dart
await user.update(displayName: 'Banana');
await user.reload();
print(user.displayName);
```



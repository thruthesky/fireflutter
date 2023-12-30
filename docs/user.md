# 사용자

많은 부분의 코드가 이미 fireship 내에 들어가 있다.

예를 들면, 회원 정보 수정이나, 공개 프로필 페이지 등은 바로 동작을 하는 상태이다. 이러한 UI 는 customize 할 수 있다.


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


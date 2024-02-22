# 위젯

fireship 에서 제공하는 기본 위젯에 대한 설명을 한다.

@TODO @thruthesky pub.dev API reference 를 보고 그곳에 나와 있는 위젯들의 사용법을 설명한다.



## LabelField

TextField 를 좀 더 쓰기 편하게 해 놓은 것이다.



## UpdateBirthday

회원 정보 수정 페이지 등에서 회원의 생년월일 정보를 보여주고 수정하게 하려면 `UpdateBirthday` 위젯을 사용하면 된다. lable 과 description 을 줄 수 있다.

예제
```dart
UpdateBirthday(
    label: '생년월일',
    description: '본인 인증에 사용되므로 올바른 생년/월/일 정보를 선택해 주세요.',
)
```



## DisplayPhotos 사진 표시


배열에 URL 을 담아서 전달하면 화면에 사진을 표시 해 준다.

```dart
DisplayPhotos(urls: List<String>.from(v ?? []))
```



## 사용자 표시

Tile 형식으로 표현하기 위해서 `UserTile` 을 쓰면 된다. 사용자 모델이 있으면 `UserTile(user: UserModel)` 와 같이 표시하면 되고, 사용자 id 만 가지고 있다면, `UserTile.fromUid(uid)` 와 같이 호출하면 된다.



## 사용자 정보 참고


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


### 사용자 정보 캐시

때로는 사용자 정보를 표시 한 다음, setState 를 호출하면, 화면이 반짝 거리는 경우가 있다. 또는 계속 해서 DB 에 접속하는 것이 마음에 들지 않는 경우가 있을 수 있다. 이와 같은 경우, cacheId 를 사용하면, 해당 cacheId 위치에서는 해당 사용자의 값(또는 필드)를 메모리에 캐시하여 사용한다.

```dart
UserDoc(cacheId: 'home');
```

또는

```dart
UserDoc.field(
      cacheId: cacheId,
      uid: uid,
      field: Field.displayName,
      builder: (data) => Text(
        data
      ),
    );
  ```
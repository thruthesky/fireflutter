# Extensions



## String extensions

You can use `orAnonymousUrl`, `orWhiteUrl`, `orBlackUrl` to display anonymous, or white, black iamge when the string of the url is empty string.

```dart
Avatar(
    photoUrl: my!.photoUrl.orAnonymousUrl,
),
```





`ifEmpty` and `or` have same fuctionality that if the string is empty, it will use the parameter value. Note that it's not working if the string is null.



`upTo` 는 처음 부터 특정 길이 만큼 문자열을 자른다.

`sanitize` 는 특수 문자를 없앤다.

`cut` 은 문자열을 특정 길이 만큼 자르는데, 중간에 특수문자도 같이 잘라 낸다. `cut` 은 `upTo` 와 `sanitize` 두 함수를 하나로 합친 것이다.



`isEmail` 은 이메일 주소인지 검사한다.


`tryInt` 와 `tryDouble` 은 int 와 double 형으로 변환한다. 변환 실패하면 null 을 반환한다.


`replace` 는 map 데이터를 받아서, 모든 데이터를 replace 한다.

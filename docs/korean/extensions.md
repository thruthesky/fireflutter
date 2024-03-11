# 익스텐션


## String extensions

문자열이 빈 문자열인 경우 익명, 흰색 또는 검정색 이미지를 표시하려면 `orAnonymousUrl`, `orWhiteUrl`, `orBlackUrl`을 사용할 수 있습니다.

```dart
Avatar(
    photoUrl: my!.photoUrl.orAnonymousUrl,
),
```

`ifEmpty`와 `or`은 문자열이 비어있을 때 매개 변수 값을 사용하는 동일한 기능을 갖고 있습니다. 문자열이 null인 경우 작동하지 않음에 유의하십시오.

`upTo` 는 처음 부터 특정 길이 만큼 문자열을 자른다.

`sanitize` 는 특수 문자를 없앤다.

`cut` 은 문자열을 특정 길이 만큼 자르는데, 중간에 특수문자도 같이 잘라 낸다. `cut` 은 `upTo` 와 `sanitize` 두 함수를 하나로 합친 것이다.

`isEmail` 은 이메일 주소인지 검사한다.

`tryInt` 와 `tryDouble` 은 int 와 double 형으로 변환한다. 변환 실패하면 null 을 반환한다.

`replace` 는 map 데이터를 받아서, 모든 데이터를 replace 한다.




`orBlocked` 는 블럭된 경우 표시할 문자열


`dateTime` 은 문자열을 DateTime 으로 변경한다. 만약, 문자열의 값이 시간 형식이 아니라서 파싱이 안되면, null 을 리턴하지 않고 현재 시간을 리턴한다.

`Ymd` 은 문자열을 DateTime 으로 변경한 다음, YYYY-MM-DD 형태로 리턴한다. 만약, 문자열의 값이 시간 형식이 아니라서 파싱이 안되면, 현재 시간을 기준으로 날짜 값을 리턴한다.

`ymd` 는 문자열을 DateTime 으로 변경한 다음, YY-MM-DD 형태로 리턴한다. 앞에 년도가 두 자리 수 이다. 만약, 문자열의 값이 시간 형식이 아니라서 파싱이 안되면, 현재 시간을 기준으로 날짜 값을 리턴한다.



`YmdHms` 는 문자열을 DateTime 으로 변경한 다음, YYYY-MM-DD HH:MM:SS 형태로 리턴한다. 만약, 문자열의 값이 시간 형식이 아니라서 파싱이 안되면, 현재 시간을 기준으로 날짜 값을 리턴한다.

`md` 는 문자열을 DateTime 으로 변경한 다음, MM-DD 형태로 리턴한다. 만약, 문자열의 값이 시간 형식이 아니라서 파싱이 안되면, 현재 시간을 기준으로 날짜 값을 리턴한다.



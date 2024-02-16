# 한국 주소 찾기

`KoreanSiGunGuSelector` 위젯을 통해 한국 관광 공사 API 를 통해서, 한국의 시/도를 먼저 선택한 다음, 시군구를 선택 할 수 있는 위젯이다.
시/도 지역은 소스 코드 내에 기록되어 api 호출 없이 보여주며, 시/도를 선택하면 api 를 통해서 시/군/구를 선택 할 수 있게 해 준다.
참고로, 시/군/구 하위의 읍/면/동은 선택은 안된다.

시/도 지역이란, 서울, 경남 등과 같이 특별시, 광역시나 팔도를 가르키는 것이며, 시/군/구란 김해시, 김해군, 강남구와 같이 시/도 내(하위)의 지역을 말한다.

각 지역에는 코드가 있는데 `sidoCode` 는 시/도를 가르키는 코드이다. `sigunguCode` 는 시/군/구를 가르키는 코드이다.

DB 에 저장 할 때, 문자열로 된 시/군/구 정보가 아닌 sidoCode 와 sigunguCode 숫자를 저장해야 한다. 그래야 DB 에서 검색(필터링)을 해야 하는 경우, 사용자가 영문이나 한글로 지역을 선택한 다음, 검색을 할 수 있다.

커스터마이징이 필요한 경우, 소스 코드를 보고 복사하여 수정해서 사용한다.




## Api Key

한국 관광 공사 API 는 Data.go.kr 공공 API 에 속한다. 그래서 data.go.kr 에 제공하는 api 키를 쓰면 되는데, 로그인하면 [마이페이지](https://www.data.go.kr/iim/main/mypageMain.do)에서 키 값을 얻을 수 있다.


## 지원 언어

한국어와 영어만 지원한다. 한국 관광 공사 API 는 일반적으로 중국어나 일본어 외에 다른 언어도 지원하는데, 시/도 정보는 사용 가능한지 살펴보지 않았다.





## 예제

- `languageCode` 에는 `ko` 와 `en` 만 지원된다.
- `apiKey` 에는 data.go.kr 에서 가져 온 키를 입력하면 된다.
- `onChangedSiDoCode` 는 `시/도` 를 선택하면 호출되는 콜백함수이다.
- `onChangedSiGunGuCode` 는 `시/군/구` 를 선택하면 호출되는 콜백함수이다.



```dart
KoreanSiGunGuSelector(
    languageCode: 'en',
    apiKey: Config.dataApiKey,
    onChangedSiDoCode: (siDo) {
        dog('시/도: $siDo');
    },
    onChangedSiGunGuCode: (siDo, siGunGu) {
        dog('시/군/구 $siDo, $siGunGu DB 에 저장 할 값: ${'${siDo.code}-${siGunGu.code}'}');
    },
),
```
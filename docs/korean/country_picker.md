# 국가 정보 선택

`CountryPicker` 에 간단한 위젯을 만들어 놓았다.

`lab` 의 국가 정보 코드 https://github.com/thruthesky/lab/blob/main/data/country-code/countries-2023-06-29.sql 를 통째로 집어 넣어서 보다 완전한 국가 코드 형태를 만들어 낸다.





## 국가 선택 예제

```dart
CountryPicker(
    onChanged: (v) {
        print(v);
    },
),
```


아래는 몇개 나라만 목록에 보여주는 예제이다.

```dart
CountryPicker(
    filters: const ['KR', 'VN', 'TH', 'LA', 'MM'],
    onChanged: (v) {
        print(v);
    },
),
```

만약 보여주는 나라 개수가 적다면, search box 를 표시 하지 않을 수 있다.

```dart
CountryPicker(
  filters: const ['KR', 'VN', 'TH', 'LA', 'MM'],
  search: false,
  onChanged: (v) {
    print(v);
  },
),
```

아래와 같이 헤더를 직접 디자인 할 수 있다.
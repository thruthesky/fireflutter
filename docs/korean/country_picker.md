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

아래와 같이 헤더와 버튼 UI 를 직접 디자인 할 수 있다.

```dart
CountryPicker(
    filters: const ['KR', 'VN', 'TH', 'LA', 'MM'],
    search: false,
    headerBuilder: () => const Text('Select your country'),
    labelBuilder: (Map<String, String> country) {
        return Text(country['name'] ?? 'Choose your country');
    },
    onChanged: (v) {
        print(v);
    },
),
```


아래와 같이 전체를 완전히 원하는 데로 디자인을 할 수 있다. 이것이 가능한 것은 내부에 있는 CountryPicker 에서 최소한의 디자인을 했기 때문이다.

```dart
SizedBox(
    width: double.infinity,
    child: Theme(
        data: Theme.of(context).copyWith(
        inputDecorationTheme:
            Theme.of(context).inputDecorationTheme.copyWith(
                    border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: context.colorScheme.primary,
                    ),
                    ),
                    contentPadding: const EdgeInsets.all(0),
                ),
        ),
        child: CountryPicker(
        // filters: const ['KR', 'VN', 'TH', 'LA', 'MM'],
        // search: false,
        headerBuilder: () => const Text('Select your country'),
        itemBuilder: (country) => Row(
            children: [
            Text(
                country.flag,
                style: TextStyle(
                fontSize:
                    Theme.of(context).textTheme.displaySmall!.fontSize,
                ),
            ),
            Expanded(
                child: Text(
                '  ${country.englishName} ',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize:
                        Theme.of(context).textTheme.titleMedium!.fontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                ),
            ),
            ],
        ),
        labelBuilder: (country) {
            if (country == null) {
            return const Text('Choose your country');
            } else {
            return Row(
                children: [
                Text("${country.flag} ${country.officialName}"),
                ],
            );
            }
        },
        onChanged: (v) {
            print(v);
        },
        ),
    ),
),
```



아래와 같이 초기 값을 줄 수 있다.

```dart
CountryPicker(
    initialValue: 'KR',
    filters: const ['KR', 'VN', 'TH', 'LA', 'MM'],
    search: false,
    headerBuilder: () => const Text('Select your country'),
    onChanged: (v) {
    nationality = v.alpha2;
    },
),
```


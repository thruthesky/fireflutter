# Country Picker

Fireflutter offers a simple widget for country picker which is `CountryPicker`.

If needed, you can receive country information from the `countryList()` function and create widgets as desired.

## Country Selection Example

```dart
CountryPicker(
    onChanged: (v) {
        print(v);
    },
),
```

Below is an example that displays only a few countries in the list.

```dart
CountryPicker(
    filters: const ['KR', 'VN', 'TH', 'LA', 'MM'],
    onChanged: (v) {
        print(v);
    },
),
```

If the number of displayed countries is small, you may choose not to display the search box.

```dart
CountryPicker(
  filters: const ['KR', 'VN', 'TH', 'LA', 'MM'],
  search: false,
  onChanged: (v) {
    print(v);
  },
),
```

You can directly design the header and button UI as follows.

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

You can fully customize everything as you want, as shown below. This is possible because minimal design is applied within the CountryPicker.

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

You can provide initial values as shown below.

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

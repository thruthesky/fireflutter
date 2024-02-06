import 'package:dio/dio.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// Korean Si/Gun/Gu Selector
///
/// Refer address.md
class KoreanSiGunGuSelector extends StatefulWidget {
  const KoreanSiGunGuSelector({
    super.key,
    required this.apiKey,
    required this.onChangedRootCode,
    required this.onChangedSecondaryCode,
    this.languageCode = 'ko',
  });

  final String apiKey;
  final String languageCode;
  final Function(AddressModel) onChangedRootCode;
  final Function(AddressModel, AddressModel) onChangedSecondaryCode;

  @override
  State<KoreanSiGunGuSelector> createState() => _KoreanSiGunGuSelectorState();
}

class _KoreanSiGunGuSelectorState extends State<KoreanSiGunGuSelector> {
  String rootCode = '';
  String secondaryCode = '';
  List<AddressModel>? secondaryAddresses;

  List<AddressModel> get rootCodes =>
      (widget.languageCode == 'ko' ? koreanRootCode : englishRootCodes)
          .map((e) => AddressModel.fromJson(e))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
                isDense: false,
                padding: const EdgeInsets.only(
                    left: 12, top: 4, right: 4, bottom: 4),
                isExpanded: true, // 화살표 아이콘을 오른쪽에 밀어 붙이기
                menuMaxHeight: 300, // 높이 조절
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Select Si/Do'),
                  ),
                  ...rootCodes.map((addr) {
                    return DropdownMenuItem(
                      value: addr.code,
                      child: Text(addr.name),
                    );
                  }).toList(),
                ],
                value: rootCode,
                onChanged: (value) {
                  setState(() {
                    rootCode = value ?? '';
                    secondaryCode = '';
                    secondaryAddresses = null;
                  });
                  widget.onChangedRootCode(
                    rootCodes.firstWhere((e) => e.code == rootCode),
                  );
                  loadSecondaryAddress(rootCode);
                }),
          ),
        ),
        if (secondaryAddresses != null) ...[
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  isDense: false,
                  padding: const EdgeInsets.only(
                      left: 12, top: 4, right: 4, bottom: 4),
                  isExpanded: true, // 화살표 아이콘을 오른쪽에 밀어 붙이기
                  menuMaxHeight: 300, // 높이 조절
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Select Region'),
                    ),
                    ...secondaryAddresses!.map((addr) {
                      return DropdownMenuItem(
                        value: addr.code,
                        child: Text(addr.name),
                      );
                    }).toList(),
                  ],
                  value: secondaryCode,
                  onChanged: (value) {
                    setState(() {
                      secondaryCode = value ?? '';

                      widget.onChangedSecondaryCode(
                        rootCodes.firstWhere((e) => e.code == rootCode),
                        secondaryAddresses!
                            .firstWhere((e) => e.code == secondaryCode),
                      );
                    });
                  }),
            ),
          ),
        ],
      ],
    );
  }

  loadSecondaryAddress(String rootCode) async {
    final dio = Dio();
    final url =
        "http://apis.data.go.kr/B551011/${widget.languageCode == 'ko' ? 'Kor' : 'Eng'}Service1/areaCode1?numOfRows=10000&pageNo=1&MobileOS=ETC&MobileApp=AppTest&_type=json&serviceKey=${widget.apiKey}&areaCode=$rootCode";

    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;
      final items = data['response']['body']['items']['item'] as List;
      secondaryAddresses = items.map((e) => AddressModel.fromJson(e)).toList();
      setState(() {});
    }
  }
}

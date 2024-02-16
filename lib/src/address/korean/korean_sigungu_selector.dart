import 'package:dio/dio.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// Korean Si/Gun/Gu Selector
///
/// Refer address.md
class KoreanSiGunGuSelector extends StatefulWidget {
  const KoreanSiGunGuSelector(
      {super.key,
      required this.apiKey,
      required this.onChangedSiDoCode,
      required this.onChangedSiGunGuCode,
      this.languageCode = 'ko',
      this.initSiDoCode,
      this.initSiGunGuCode,
      this.showLoading = true});

  final String apiKey;
  final String languageCode;
  final Function(AddressModel) onChangedSiDoCode;
  final Function(AddressModel, AddressModel) onChangedSiGunGuCode;
  // for review sir song
  final String? initSiDoCode;
  final String? initSiGunGuCode;
  final bool showLoading;

  @override
  State<KoreanSiGunGuSelector> createState() => _KoreanSiGunGuSelectorState();
}

class _KoreanSiGunGuSelectorState extends State<KoreanSiGunGuSelector> {
  String siDoCode = '';
  String siGunGuCode = '';
  List<AddressModel>? secondaryAddresses;
  bool isLoading = false;

  List<AddressModel> get rootCodes =>
      (widget.languageCode == 'ko' ? koreanRootCode : englishRootCodes)
          .map((e) => AddressModel.fromJson(e))
          .toList();

  // for review sir song
  @override
  void initState() {
    super.initState();
    siDoCode = widget.initSiDoCode ?? '';
    siGunGuCode = widget.initSiGunGuCode ?? '';

    if (widget.initSiDoCode != null) {
      loadSecondaryAddress(widget.initSiDoCode ?? '');
    }
  }

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
                    child: Text('Select Province'),
                  ),
                  ...rootCodes.map((addr) {
                    return DropdownMenuItem(
                      value: addr.code,
                      child: Text(addr.name),
                    );
                  }).toList(),
                ],
                value: siDoCode,
                onChanged: (value) {
                  setState(() {
                    siDoCode = value ?? '';
                    siGunGuCode = '';
                    secondaryAddresses = null;
                  });
                  widget.onChangedSiDoCode(
                    rootCodes.firstWhere((e) => e.code == siDoCode),
                  );
                  loadSecondaryAddress(siDoCode);
                }),
          ),
        ),
        // for review sir song
        if (widget.showLoading) ...{
          if (isLoading) ...{
            const SizedBox(
              height: 8,
            ),
            const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          },
        },
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
                  value: siGunGuCode,
                  onChanged: (value) {
                    setState(() {
                      siGunGuCode = value ?? '';
                      widget.onChangedSiGunGuCode(
                        rootCodes.firstWhere((e) => e.code == siDoCode),
                        secondaryAddresses!
                            .firstWhere((e) => e.code == siGunGuCode),
                      );
                    });
                  }),
            ),
          ),
        ],
      ],
    );
  }

  loadSecondaryAddress(String siDoCode) async {
    setState(() {
      isLoading = true;
    });

    final dio = Dio();
    final url =
        "http://apis.data.go.kr/B551011/${widget.languageCode == 'ko' ? 'Kor' : 'Eng'}Service1/areaCode1?numOfRows=10000&pageNo=1&MobileOS=ETC&MobileApp=AppTest&_type=json&serviceKey=${widget.apiKey}&areaCode=$siDoCode";

    final response = await dio.get(url);
    if (!mounted) {
      return;
    }
    if (response.statusCode == 200) {
      final data = response.data;
      final items = data['response']['body']['items']['item'] as List;
      secondaryAddresses = items.map((e) => AddressModel.fromJson(e)).toList();
      setState(() {});
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

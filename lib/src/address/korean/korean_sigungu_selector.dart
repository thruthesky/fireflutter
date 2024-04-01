import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Korean Si/Gun/Gu Selector
///
/// Refer address.md
class KoreanSiGunGuSelector extends StatefulWidget {
  const KoreanSiGunGuSelector({
    super.key,
    required this.onChangedSiDoCode,
    required this.onChangedSiGunGuCode,
    this.languageCode = 'ko',
    this.initSiDoCode,
    this.initSiGunGuCode,
    this.showSiGunGu = false,
  });

  final String languageCode;
  final Function(AreaCode?) onChangedSiDoCode;
  final Function(AreaCode, AreaCode?) onChangedSiGunGuCode;
  final String? initSiDoCode;
  final String? initSiGunGuCode;

  // adding showSiGunGu this property will dispplay the SiGunGu dropdown but if
  // siDo is not selected or not exist the dropdown is disable.
  final bool showSiGunGu;

  @override
  State<KoreanSiGunGuSelector> createState() => _KoreanSiGunGuSelectorState();
}

class _KoreanSiGunGuSelectorState extends State<KoreanSiGunGuSelector> {
  String? siDoCode;
  String? siGunGuCode;
  List<AreaCode>? secondaryAddresses;

  @override
  void initState() {
    super.initState();
    siDoCode = widget.initSiDoCode;
    siGunGuCode = widget.initSiGunGuCode;

    if (widget.initSiDoCode != null) {
      secondaryAddresses = getSiGunGuCodes(
        languageCode: widget.languageCode,
        siDo: widget.initSiDoCode!,
      );
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
                  DropdownMenuItem(
                    value: null,
                    child: Text(T.selectProvince.tr),
                  ),
                  ...getSiDoCodes(languageCode: widget.languageCode)
                      .map((addr) {
                    return DropdownMenuItem(
                      value: addr.code,
                      child: Text(addr.name),
                    );
                  }),
                ],
                value: siDoCode,
                onChanged: (value) {
                  siDoCode = value;
                  siGunGuCode = null;
                  if (siDoCode != null) {
                    secondaryAddresses = getSiGunGuCodes(
                      languageCode: widget.languageCode,
                      siDo: siDoCode!,
                    );
                  }

                  setState(() {});
                  widget.onChangedSiDoCode(
                    siDoCode == null
                        ? null
                        : getSiDoCodes(languageCode: widget.languageCode)
                            .firstWhere((e) => e.code == siDoCode),
                  );
                }),
          ),
        ),
        if (siDoCode != null || widget.showSiGunGu) ...[
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
                    DropdownMenuItem(
                      value: null,
                      child: Text(siDoCode != null
                          ? T.selectProvince.tr
                          : T.noSelectTedRegion.tr),
                    ),
                    if (siDoCode != null) ...{
                      ...secondaryAddresses!.map((addr) {
                        return DropdownMenuItem(
                          value: addr.code,
                          child: Text(addr.name),
                        );
                      }),
                    }
                  ],
                  value: siGunGuCode,
                  onChanged: siDoCode != null
                      ? (value) {
                          setState(() {
                            siGunGuCode = value;
                          });

                          widget.onChangedSiGunGuCode(
                              getSiDoCodes(languageCode: widget.languageCode)
                                  .firstWhere((e) => e.code == siDoCode),
                              siGunGuCode == null
                                  ? null
                                  : secondaryAddresses!.firstWhere(
                                      (e) => e.code == siGunGuCode));
                        }
                      : null),
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// PopupSelectField
///
/// 텍스트 필드를 누르면 팝업창이 뜨고, 목록한 값들 중에서 하나를 선택 할 수 있도록 하는 텍스트 필드형 위젯
/// PopupTextField 와 비슷한 UI 로 표현하고자 할 때 사용 할 수 있으며, 팝업창에서 목록한 값들 중에서
/// 하나를 선택할 수 있다.
///
/// [label] 필드의 라벨
///
/// [typeHint] 필드의 타입힌트
/// 필드에 아무것도 입력되지 않았을 때 표시되는 텍스트. 무언가를 선택하거나, 옵션에서 [initialValue]가 지정되면 사라진다.
/// PopupTextField 와는 다르게, typeHint 는 팝업창에서 설명으로 사용된다.
///
/// [initialValue] 필드의 초기값
/// 필드에 표시되는 초기값. 팝업창에서 기본적으로 이 값이 선택되어져 보인다.
///
/// [onChange] 선택된 값이 변경될 때 호출되는 콜백함수
///
/// [items] value 와 label 로 이루어진 목록. 선택 목록에 label 이 보이고, 실제 값은 value 가 된다.
///
class PopupSelectField extends StatefulWidget {
  const PopupSelectField({
    super.key,
    required this.label,
    required this.typeHint,
    this.initialValue,
    required this.items,
    required this.onChange,
  });

  final String label;
  final String typeHint;
  final String? initialValue;
  final List<Map<String, String>> items;
  final void Function(String) onChange;

  @override
  State<PopupSelectField> createState() => _PopupSelectFieldState();
}

class _PopupSelectFieldState extends State<PopupSelectField> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (selectedValue != null) {
        widget.onChange(selectedValue!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final result = await showDialog<String>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label),
                  Text(
                    widget.typeHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var item in widget.items)
                    ListTile(
                      leading: item['value'] == selectedValue
                          ? const Icon(Icons.check)
                          : null,
                      title: Text(item['label']!),
                      onTap: () {
                        Navigator.pop(context, item['value']);
                      },
                    ),
                ],
              ),
            );
          },
        );

        if (result != null) {
          /// 새로 값이 변경되어야지만, setState를 호출하고, 콜백함수를 호출한다.
          if (selectedValue != result) {
            setState(() {
              selectedValue = result;
            });
            widget.onChange(result);
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Text(
            (selectedValue ?? '') == ''
                ? widget.typeHint
                : widget.items.firstWhere(
                    (element) => element['value'] == selectedValue,
                    orElse: () => {'label': widget.typeHint})['label']!,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

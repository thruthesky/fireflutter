import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// PopupTextField
///
/// 텍스트 필드를 누르면 팝업창이 뜨고, 입력한 값을 받아서 텍스트 필드에 표시한다.
///
/// [label] 텍스트 필드의 라벨
///
/// [typeHint] 텍스트 필드의 타입힌트
/// 텍스트 필드에 아무것도 입력되지 않았을 때 표시되는 텍스트. 사용자가 무언가를 입력거나, 옵션에서 [initialData]가 지정되면 사라진다.
///
/// [initialData] 텍스트 필드의 초기값
/// 텍스트 필드에 표시되는 초기값. 팝업창에서 기본적으로 이 값이 입력되어져 보인다. 만약, 사용자가 터치했을 때 이 값이
/// 없어지기를 바란다면, [typeHint]를 사용하면 된다.
///
/// [onChange] 텍스트 필드의 값이 변경될 때 호출되는 콜백함수
class PopupTextField extends StatefulWidget {
  const PopupTextField({
    super.key,
    required this.label,
    required this.typeHint,
    this.initialData,
    required this.onChange,
  });

  final String label;
  final String typeHint;
  final String? initialData;
  final void Function(String) onChange;

  @override
  State<PopupTextField> createState() => _PopupTextFieldState();
}

class _PopupTextFieldState extends State<PopupTextField> {
  final controller = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    controller.text = widget.initialData ?? '';
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.initialData != null) {
        widget.onChange(controller.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        /// 이전 값
        final prev = controller.text;
        final result = await showDialog<String>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(widget.label),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: widget.typeHint,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, controller.text);
                  },
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );

        if (result != null) {
          /// 새로 값이 변경되어야지만, setState를 호출하고, 콜백함수를 호출한다.
          if (prev != result) {
            setState(() {});
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
          Text(controller.text.or(widget.typeHint),
              style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}

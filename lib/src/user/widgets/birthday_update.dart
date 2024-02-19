import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class BirthdayUpdate extends StatefulWidget {
  const BirthdayUpdate({
    super.key,
    this.label,
    this.description,
  });

  final String? label;
  final String? description;

  @override
  State<BirthdayUpdate> createState() => _BirthdayUpdateState();
}

class _BirthdayUpdateState extends State<BirthdayUpdate> {
  @override
  Widget build(BuildContext context) {
    return MyDoc(builder: (my) {
      if (my == null) {
        return const SizedBox();
      }
      return TextWithLable(
        label: widget.label, // '생년월일',
        description: widget.description,
        text: my.birthYear == 0
            ? T.birthdateTapToSelect.tr // '탭하셔서 생년월일을 선택해주세요.'
            : T.birthdate.tr
                .replaceAll(
                  '#birthYear',
                  my.birthYear.toString(),
                )
                .replaceAll(
                  '#birthMonth',
                  my.birthMonth.toString(),
                )
                .replaceAll(
                  '#birthDay',
                  my.birthDay.toString(),
                ),
        onTap: () async {
          showDialog(
            context: context,
            builder: (context) => const BirthdayPickerDialog(),
          );
        },
      );
    });
  }
}

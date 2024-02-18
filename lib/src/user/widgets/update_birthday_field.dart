import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

@Deprecated('Use UpdateBirthday instead')
class UpdateBirthdayField extends StatefulWidget {
  const UpdateBirthdayField({
    super.key,
    required this.user,
    this.displayLabel = true,
  });

  final UserModel user;
  final bool displayLabel;

  @override
  State<UpdateBirthdayField> createState() => _UpdateBirthdayState();
}

class _UpdateBirthdayState extends State<UpdateBirthdayField> {
  TextEditingController controller = TextEditingController();

  int birthYear = 0;
  int birthMonth = 0;
  int birthDay = 0;

  @override
  void initState() {
    super.initState();
    controller.text = widget.user.name;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        birthYear = widget.user.birthYear;
        birthMonth = widget.user.birthMonth;
        birthDay = widget.user.birthDay;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextWithLable(
      label: widget.displayLabel ? T.birthdateLabel.tr : null, // '생년월일',
      description:
          T.birthdateSelectDescription.tr, // '본인 인증에 필요하므로 정확히 입력해주세요.',
      text: widget.user.birthYear == 0
          ? T.birthdateTapToSelect.tr // '탭하셔서 생년월일을 선택해주세요.'
          : T.birthdate.tr
              .replaceAll(
                '#birthYear',
                widget.user.birthYear.toString(),
              )
              .replaceAll(
                '#birthMonth',
                widget.user.birthMonth.toString(),
              )
              .replaceAll(
                '#birthDay',
                widget.user.birthDay.toString(),
              ),
      onTap: () async {
        showDialog(
          context: context,
          builder: (context) => const BirthdayPickerDialog(),
        );
      },
    );
  }
}

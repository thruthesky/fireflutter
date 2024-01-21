import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class UpdateBirthdayField extends StatefulWidget {
  const UpdateBirthdayField({super.key, required this.user});

  final UserModel user;

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
      label: '생년월일',
      description: '본인 인증에 필요하므로 정확히 입력해주세요.',
      text: widget.user.birthYear == 0
          ? '탭하셔서 생년월일을 선택해주세요.'
          : '${widget.user.birthYear}년 ${widget.user.birthMonth}월 ${widget.user.birthDay}일',
      onTap: () async {
        showDialog(
          context: context,
          builder: (context) => const BirthdayPickerDialog(),
        );
      },
    );
  }
}

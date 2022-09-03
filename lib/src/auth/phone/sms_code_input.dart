import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class SmsCodeInput extends StatefulWidget {
  SmsCodeInput({
    required this.success,
    this.submitTitle = const SizedBox.shrink(),
    required this.buttons,
    this.smsCodeInputDecoration = const InputDecoration(),
    this.smsCodeInputTextStyle = const TextStyle(),
    Key? key,
  }) : super(key: key);

  /// [success] will be called after verification success.
  final VoidCallback success;

  final Widget Function(VoidNullableCallback submit) buttons;
  final Widget submitTitle;

  final InputDecoration smsCodeInputDecoration;
  final TextStyle smsCodeInputTextStyle;

  @override
  _SmsCodeInputState createState() => _SmsCodeInputState();
}

class _SmsCodeInputState extends State<SmsCodeInput> {
  @override
  void initState() {
    super.initState();
    PhoneService.instance.verifySentProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (t) => setState(() => PhoneService.instance.smsCode = t),
          style: widget.smsCodeInputTextStyle,
          decoration: widget.smsCodeInputDecoration,
          keyboardType: TextInputType.number,
        ),
        widget.submitTitle,
        widget.buttons(submit),
      ],
    );
  }

  submit() async {
    setState(() {
      PhoneService.instance.verifySentProgress = true;
    });
    try {
      await PhoneService.instance.verifySMSCode(
        success: widget.success,
      );
    } catch (e) {
      // 에러메시지가 PhoneService::verifyCredential() 에서 화면에 노출된다.
      // ffAlert(context, 'SMS Code Error', e.toString());
      rethrow;
    } finally {
      setState(() {
        if (mounted) PhoneService.instance.verifySentProgress = false;
      });
    }
  }
}

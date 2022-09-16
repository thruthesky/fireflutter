import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';

class PhoneNumberInput extends StatefulWidget {
  PhoneNumberInput({
    this.favorites = const ['US', 'KR'],
    this.onChanged,
    required this.countryButtonBuilder,
    required this.countrySelectedBuilder,
    required this.codeSent,
    required this.success,
    required this.codeAutoRetrievalTimeout,
    this.inputTitle = const SizedBox.shrink(),
    this.phoneNumberContainerBuilder,
    this.dialCodeStyle = const TextStyle(fontSize: 24),
    this.phoneNumberInputDecoration =
        const InputDecoration(border: InputBorder.none),
    this.phoneNumberInputTextStyle = const TextStyle(),
    this.submitTitle = const SizedBox.shrink(),
    this.submitButton = const Text(
      'Submit',
      style: TextStyle(color: Colors.blue, fontSize: 24),
    ),
    this.progress = const CircularProgressIndicator.adaptive(),
    Key? key,
  }) : super(key: key);

  final List<String> favorites;
  final void Function(CountryCode)? onChanged;
  final Widget Function() countryButtonBuilder;
  final Widget Function(CountryCode) countrySelectedBuilder;
  final void Function(String verificationId) codeSent;
  final VoidCallback success;
  final void Function(String) codeAutoRetrievalTimeout;
  final Widget Function(Widget)? phoneNumberContainerBuilder;
  final TextStyle dialCodeStyle;
  final InputDecoration phoneNumberInputDecoration;
  final TextStyle phoneNumberInputTextStyle;
  final Widget submitButton;
  final Widget inputTitle;
  final Widget submitTitle;
  final Widget progress;

  @override
  _PhoneNumberInputState createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<PhoneNumberInput> {
  @override
  void initState() {
    super.initState();
    PhoneService.instance.reset();
  }

  @override
  Widget build(BuildContext context) {
    Widget phoneNumber = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          PhoneService.instance.selectedCode?.dialCode! ?? '',
          style: widget.dialCodeStyle,
        ),
        SizedBox(width: 8),
        Expanded(
          child: TextField(
            style: widget.phoneNumberInputTextStyle,
            decoration: widget.phoneNumberInputDecoration,
            keyboardType: TextInputType.phone,
            onChanged: (t) {
              setState(() {
                PhoneService.instance.domesticPhoneNumber = t;
                PhoneService.instance.codeSentProgress = false;
              });
            },
          ),
        ),
      ],
    );
    if (widget.phoneNumberContainerBuilder != null) {
      phoneNumber = widget.phoneNumberContainerBuilder!(phoneNumber);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CountryCodePicker(
          onChanged: (CountryCode code) {
            PhoneService.instance.selectedCode = code;
            if (widget.onChanged != null) widget.onChanged!(code);
            setState(() {});
          },
          favorite: widget.favorites,
          comparator: (a, b) {
            /// sort by country dial code
            int re = b.dialCode!.compareTo(a.dialCode!);
            return re == 0 ? 0 : (re < 0 ? 1 : -1);
          },
          builder: (CountryCode? code) {
            return PhoneService.instance.selectedCode == null
                ? widget.countryButtonBuilder()
                : widget.countrySelectedBuilder(code!);
          },
        ),
        if (PhoneService.instance.selectedCode != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.inputTitle,
              phoneNumber,
            ],
          ),
        if (PhoneService.instance.domesticPhoneNumber != '')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.submitTitle,
              PhoneService.instance.codeSentProgress
                  ? widget.progress
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          PhoneService.instance.codeSentProgress = true;
                        });
                        PhoneService.instance.phoneNumber =
                            PhoneService.instance.completeNumber;
                        // print( 'phone number: ${PhoneService.instance.phoneNumber}');
                        PhoneService.instance.verifyPhoneNumber(
                          error: () => setState(() => {}),
                          codeSent: (verificationId) {
                            widget.codeSent(verificationId);
                            setState(() {
                              PhoneService.instance.codeSentProgress = false;
                            });
                          },
                          androidAutomaticVerificationSuccess: widget.success,
                          codeAutoRetrievalTimeout:
                              widget.codeAutoRetrievalTimeout,
                        );
                      },
                      child: widget.submitButton,
                    ),
            ],
          ),
      ],
    );
  }
}

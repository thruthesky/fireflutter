import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// A simple phone number login form.
///
/// 간단한 전화번호 로그인 위젯. 이 위젯은 전화번호를 입력하고, SMS 코드를 입력하는 UI 를 보여준다.
/// 참고로, 이메일로 로그인을 할 수도 있다.
/// 참고로, 국가 코드 선택을 하지는 않는다. 따라서 국가 코드 선택이 필요한 경우, 이 위젯의 코드를 복사해서 수정해서 사용하면 된다.
///
/// 리뷰 또는 테스트를 위해서 [emailLogin], [reviewEmail], [reviewPassword],
/// [reviewPhoneNumber], [reviewRealPhoneNumber], [reviewRealSmsCode] 와 같은
/// 값을 사용 할 수 있다. 만약 리뷰나 테스트 용 로그인이 아니면, 이 값들은 필요 없다.
///
/// [emailLogin] 이 true 이며, 전화번호에 @ 이 포함되어 있으면, 이메일과 비밀번호로 로그인을 한다.
/// 이메일과 비밀번호는 : 로 분리해서 입력한다. 예) my@email.com:4321Pw 와 같이 하면, 메일 주소는
/// my@email.com 이고, 비밀번호는 4321Pw 이다.
///
/// [reviewEmail] Review 용 임시 이메일.
/// [reviewPhoneNumber] 나 [reviewRealPhoneNumber] 를 입력하면, 이 이메일 계정으로 로그인한다.
///
/// [reviewPassword] 는 [reviewEmail] 과 함께 사용되는 리뷰용 임시 비밀번호.
/// [emailLogin] 이 true 인 경우, "[reviewEmail]:[reviewPassword]" 와 같이 입력하면, 리뷰
/// 계정으로 로그인한다.
///
/// [reviewPhoneNumber] Review 용 임시 전화번호. 이 값을 전화번호로 입력하면, 리뷰 계정으로 자동 로그인.
/// 예를 들어, 이 값이 '01012345678' 으로 지정되고, 사용자가 이 값을 입력하면, 곧 바로 리뷰 [reviewEmail]
/// 계정으로 로그인한다. SMS 코드를 입력 할 필요 없이, 바로 로그인한다.
///
/// [reviewRealPhoneNumber] 테스트 전화번호. 이 값을 전화번호로 입력하면, 테스트 SMS 코드를 입력하게 한다.
/// 예를 들어, 이 값이 '01012345678' 으로 지정되고, 사용자가 이 값을 입력하면, 테스트 SMS 코드를 입력하게 한다.
///
/// [reviewRealSmsCode] 리뷰 할 때 사용하는 SMS 코드. [reviewRealPhoneNumber] 를 입력 한 다음,
/// 이 값을 SMS 코드로 입력하면, [reviewEmail] 계정으로 자동 로그인.
/// 즉, [reviewRealPhoneNumber] 을 입력하고, [reviewRealSmsCode] 를 입력하면, 테스트 계정으로 로그인한다. 이것은
/// 애플 리뷰에서 리뷰 계정 로그인을 할 때, 로그인 전체 과정을 다 보여달라고 하는 경우, 이 [reviewRealPhoneNumber] 와
/// [reviewRealSmsCode] 를 알려주면 된다.
///
///
/// [onCompleteNumber] 전화번호 입력을 하고, 전송 버튼을 누르면 이 콜백을 호출한다. 이 콜백은 전화번호를 받아서,
/// 전화번호가 올바른지 또는 전화번호를 원하는 형태로 수정해서 반환한다. 예를 들어, 한국 전화번호와 필리핀 전화번호 두 가지만 입력
/// 받고 싶은 경우, 한국 전화번호는 010 로 시작하고, 필리핀 전화번호는 09로 시작한다. 그래서 전화번호의 처음 숫자를 보고
/// +82 또는 +63을 붙여 완전한 국제 전화번호로 리턴하면 된다.
///
/// [onSignin] 로그인이 성공하면 호출되는 콜백. 홈 화면으로 이동하거나 기타 작업을 할 수 있다.
///
/// 로그인이 성성하면 이 위젯은 UserService.instance.login() 을 호출한다. 그리고 처음 로그인이면, 이 함수에서
/// /users/<uid> 를 생성한다.
class SimplePhoneSignInForm extends StatefulWidget {
  const SimplePhoneSignInForm({
    super.key,
    this.emailLogin = false,
    this.reviewEmail = 'review@email.com',
    this.reviewPassword = '12345a',
    this.reviewPhoneNumber,
    this.reviewRealPhoneNumber,
    this.reviewRealSmsCode,
    this.onCompleteNumber,
    required this.onSignin,
    this.languageCode = 'ko',
    this.headerTitleTextAlign,
  });

  final bool emailLogin;
  final String reviewEmail;
  final String reviewPassword;
  final String? reviewPhoneNumber;
  final String? reviewRealPhoneNumber;
  final String? reviewRealSmsCode;
  final String Function(String)? onCompleteNumber;
  final void Function() onSignin;
  final String languageCode;
  final TextAlign? headerTitleTextAlign;

  @override
  State<SimplePhoneSignInForm> createState() => _SimplePhoneSignInState();
}

class _SimplePhoneSignInState extends State<SimplePhoneSignInForm> {
  bool showSmsCodeInput = false; // 테스트 할 때, true 로 할 것.
  final phoneNumberController =
      TextEditingController(text: ""); // 테스트 할 때, 임시 전화번호 입력. 예: 010-1234-5678
  final smsCodeController = TextEditingController();

  String? verificationId;
  bool progressVerifyPhoneNumber = false;
  bool smsCodeProgress = false;

  String get completeNumber {
    String number = phoneNumberController.text.trim();
    number = number.replaceAll(RegExp(r'[^\+0-9]'), '');
    number = number.replaceFirst(RegExp(r'^0'), '');
    number = number.replaceAll(' ', '');

    if (number == widget.reviewPhoneNumber ||
        number == widget.reviewRealPhoneNumber) {
      return number;
    }
    return widget.onCompleteNumber?.call(number) ?? number;
  }

  bool get isRealReviewSmsCode {
    return completeNumber == widget.reviewRealPhoneNumber &&
        smsCodeController.text == widget.reviewRealSmsCode;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          T.phoneSignInHeaderTitle.tr,
          style: Theme.of(context).textTheme.labelMedium,
          textAlign: widget.headerTitleTextAlign,
        ),
        const SizedBox(height: 32),
        // 전화번호를 입력하고, SMS 코드 전송하고, 코드 입력하는 UI 를 보여주는가?
        showSmsCodeInput
            // 그렇다면 전화번호 입력 UI 대신, 전화번호만 보여준다.
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  "phone",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  completeNumber,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ])
            // 전화번호 입력을 다 안했으면, SMS 코드 전송을 안했으면, 전화번호 입력 UI를 보여준다.
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    T.phoneNumber.tr,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      isDense: true,
                      // contentPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                      border: const OutlineInputBorder(),
                      hintText: T.phoneNumberInputHint.tr,
                      hintStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.outline.tone(72),
                      ),
                    ),
                    style: const TextStyle(fontSize: 24),
                    autofocus: true,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    T.phoneNumberInputDescription.tr,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
              ),
        if (showSmsCodeInput == false) const SizedBox(height: 32),
        if (showSmsCodeInput == false)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (phoneNumberController.text.trim().isEmpty ||
                        progressVerifyPhoneNumber)
                    ? null
                    : () async {
                        // 전화번호에 @ 이 포함되어 있으면, 이메일과 비밀번호로 로그인을 한다.
                        if (widget.emailLogin &&
                            phoneNumberController.text.contains('@')) {
                          return doEmailLogin();
                        } else if (completeNumber == widget.reviewPhoneNumber) {
                          // 리뷰 전화번호. 리뷰 이메일 계정으로 로그인.
                          return doReviewPhoneNumberLogin();
                        } else if (completeNumber ==
                            widget.reviewRealPhoneNumber) {
                          // 테스트 전화번호. 실제 전화번호인 것 처럼 동작.
                          return doReviewRealPhoneNumberLogin();
                        }

                        FirebaseAuth.instance
                            .setLanguageCode(widget.languageCode);
                        setState(() => progressVerifyPhoneNumber = true);
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          timeout: const Duration(seconds: 120),
                          phoneNumber: completeNumber,
                          // Android Only. Automatic SMS code resolved. Just go home.
                          verificationCompleted:
                              (PhoneAuthCredential credential) async {
                            // 안드로이드에서 자동으로 로그인하면, 앱이 메인 화면으로 이동한 후, 로그인 time expire 나
                            // invalid sms code 에러가 발생할 수 있다.
                            // 이런 경우, 에러를 무시해도 된다.
                            // Sign the user in (or link) with the auto-generated credential
                            await FirebaseAuth.instance
                                .signInWithCredential(credential);
                            setState(() => progressVerifyPhoneNumber = false);
                            signinSuccess();
                          },
                          // Phone number verification failed or there is an error on Firebase like quota exceeded.
                          // This is not for the failures of SMS code verification!!
                          verificationFailed: (FirebaseAuthException e) {
                            setState(() => progressVerifyPhoneNumber = false);
                            error(
                                context: context,
                                title: T.error.tr,
                                message: e.toString());
                          },
                          // Phone number verfied and SMS code sent to user.
                          // Show SMS code input UI.
                          codeSent: (String verificationId, int? resendToken) {
                            this.verificationId = verificationId;
                            setState(() {
                              showSmsCodeInput = true;
                              progressVerifyPhoneNumber = false;
                            });
                          },
                          // Only for Android. This timeout may happens when the Phone Signal is not stable.
                          codeAutoRetrievalTimeout: (String verificationId) {
                            // Auto-resolution timed out...
                            if (mounted) {
                              error(
                                  context: context,
                                  title: T.error.tr,
                                  message: T.phoneSignInTimeoutTryAgain.tr);
                              setState(() {
                                showSmsCodeInput = false;
                                progressVerifyPhoneNumber = false;
                              });
                            }
                          },
                        );
                      },
                child: progressVerifyPhoneNumber
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        T.phoneSignInGetVerificationCode.tr,
                      ),
              ),
            ],
          ),
        if (showSmsCodeInput) ...[
          const SizedBox(height: 32),
          Text(T.phoneSignInInputSmsCode.tr,
              style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          TextField(
            controller: smsCodeController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            autofocus: true,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: () => setState(() {
                  showSmsCodeInput = false;
                  smsCodeController.text = '';
                }),
                child: Text(
                  T.phoneSignInRetry.tr,
                ),
              ),
              const Spacer(),
              // display a button for SMS code verification.
              ElevatedButton(
                onPressed: () async {
                  // 테스트 전화번호. 실제 전화번호 인 것 처럼 동작. 가짜 전화번호와 가짜 SMS 코드를 입력하게 해서 로그인.
                  if (isRealReviewSmsCode) {
                    return doReviewLogin();
                  }

                  // Create a PhoneAuthCredential with the code
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: verificationId!,
                      smsCode: smsCodeController.text);

                  setState(() => smsCodeProgress = true);
                  try {
                    // Sign the user in (or link) with the credential
                    await FirebaseAuth.instance
                        .signInWithCredential(credential);
                    signinSuccess();
                  } catch (e) {
                    // SMS Code verification error comes here.
                    if (context.mounted) {
                      error(
                        context: context,
                        title: T.error.tr,
                        message: e.toString(),
                      );
                    }
                  } finally {
                    setState(() => smsCodeProgress = false);
                  }
                },
                child: smsCodeProgress
                    ? const CircularProgressIndicator.adaptive()
                    : Text(T.phoneSignInVerifySmsCode.tr),
              ),
            ],
          ),
        ],
      ],
    );
  }

  signinSuccess() async {
    await UserService.instance.login();
    widget.onSignin.call();
  }

  doReviewLogin() async {
    await loginOrRegister(
      email: widget.reviewEmail,
      password: widget.reviewPassword,
    );
    signinSuccess();
  }

  doEmailLogin() async {
    setState(() => progressVerifyPhoneNumber = true);
    try {
      // 전화번호 중간에 @ 이 있으면 : 로 분리해서, 이메일과 비밀번호로 로그인을 한다.
      // 예) test9@email.com:12345a
      final email = phoneNumberController.text.split(':').first;
      final password = phoneNumberController.text.split(':').last;
      await loginOrRegister(
        email: email,
        password: password,
        photoUrl: '',
      );
      signinSuccess();
    } finally {
      setState(() => progressVerifyPhoneNumber = false);
    }
  }

  doReviewPhoneNumberLogin() async {
    setState(() => progressVerifyPhoneNumber = true);
    return doReviewLogin();
  }

  doReviewRealPhoneNumberLogin() {
    setState(() {
      showSmsCodeInput = true;
      progressVerifyPhoneNumber = false;
    });
  }
}

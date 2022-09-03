import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';

typedef CodeSentCallback = void Function(String verificationId);

class PhoneService {
  static PhoneService? _instance;
  static PhoneService get instance {
    _instance ??= PhoneService();
    return _instance!;
  }

  PhoneAuthCredential? credential;

  /// Selected country code.
  ///
  /// This is used for Phone Sign In UI only.
  CountryCode? selectedCode;

  /// Phone number without country dial code. used in Phone Sign In UI only
  String domesticPhoneNumber = '';

  /// Remove the leading '0' from phone number and non-numeric characters.
  String get completeNumber {
    // Remove non-numeric character including white spaces, dash,
    String str = domesticPhoneNumber.replaceAll(RegExp(r"\D"), "");
    if (str[0] == '0') str = str.substring(1);

    return selectedCode!.dialCode! + str;
  }

  /// This is used only for sign in ui.
  /// Since [PhoneService.instance] is singleton, it needs to reset progress bar also.
  bool codeSentProgress = false;
  bool verifySentProgress = false;

  ///
  String phoneNumber = '';
  String verificationId = '';
  String smsCode = '';
  int? resendToken;

  /// Get complete phone number in standard format.
  // String get completePhoneNumber => selectedCode!.dialCode! + phoneNumber;

  /// [verified] becomes true once phone auth has been successfully verified.
  bool verified = false;

  reset() {
    selectedCode = null;
    phoneNumber = '';
    domesticPhoneNumber = '';
    verificationId = '';
    smsCode = '';
    codeSentProgress = false;
    verifySentProgress = false;
    resendToken = null;
  }

  /// This method is invoked when user submit sms code, then it will begin
  /// verification process.
  Future verifySMSCode({required VoidCallback success}) {
    // log("---> PhoneService::verifiySMSCode()");
    // Get credential
    credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);

    // Verify credential
    return verifyCredential(credential!, success: success);
  }

  /// Verify SMS code credential
  ///
  /// Logic
  ///   - User entered phone number,
  ///   - And verifyPhonenumber() is invoked,
  ///   - And sms has been sent to user
  ///   - User entered sms code,
  ///   - Then, this method is invokded.
  Future verifyCredential(PhoneAuthCredential credential,
      {required VoidCallback success}) async {
    /// 참고: https://docs.google.com/document/d/12sZ8VTryUiPsjCu7c1iqXQCoNbF5qiUlrmhWxP7DGjM/edit#heading=h.uzwakaird0ci

    try {
      final re = await UserService.instance
          .phoneNumberExists(PhoneService.instance.completeNumber);

      if (re) {
        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        log("---> [OK] The phone number (${PhoneService.instance.completeNumber}) already in use. So, do 'signInWithCredential()' and success; userCredential: $userCredential");
      } else {
        final userCredential = await FirebaseAuth.instance.currentUser
            ?.linkWithCredential(credential);
        log("---> [OK] The phone number (${PhoneService.instance.completeNumber}) not in use. So, do 'linkWithCredential()' and success; userCredential: $userCredential");
      }
    } on FirebaseAuthException catch (e) {
      FireFlutter.instance.alert("Sign-in Error", e.toString());
      rethrow;
    }

    /// If there is no error, then sms code verification had been succeed.
    verified = true;

    /// Note that, when this succeed, `FirebaseAuth.instance.authStateChanges`
    /// will happen, and firebase_auth User data has the phone number.
    /// If you want to get user's phone number, you get it there.
    success();
  }

  /// When user submit his phone number, verify the phone numbrer first before
  /// sending sms code.
  ///
  /// on `codeSent`, move to sms code input screen since SMS code has been delivered to user.
  /// on `codeAutoRetrievalTimeout`, alert user that sms code timed out. and redirect to phone number input screen.
  /// on `error`, display error.
  /// on `androidAutomaticVerificationSuccess` handler will be called on phone verification complete.
  /// This `androidAutomaticVerificationSuccess` handler is only for android that may do automatic sms code resolution and verify the phone auth.
  Future<void> verifyPhoneNumber({
    required CodeSentCallback codeSent,
    required VoidStringCallback codeAutoRetrievalTimeout,
    required VoidCallback androidAutomaticVerificationSuccess,
    // required ErrorCallback error,
  }) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      /// Automatic SMS code resolution for Android only.
      ///
      /// 사용자 로그인 credential 을 인증한 것이 아니라, SMS Code 만 올바로 인증이 되었다는 것이다.
      /// 즉, 사용자 인증은 verifyCredential 에서 한다.
      ///
      /// Note that, not all Android phone support automatic sms resolution.
      verificationCompleted: (PhoneAuthCredential c) {
        log('--> verificationComplete;');
        credential = c;
        verifyCredential(c, success: androidAutomaticVerificationSuccess);
      },
      verificationFailed: (FirebaseAuthException e) {
        FireFlutter.instance.alert("Phone Verification Error", e.toString());
        throw Exception(e);
      },
      codeSent: (String verificationId, resendToken) {
        this.verificationId = verificationId;
        this.resendToken = resendToken;
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (verified) return;
        codeAutoRetrievalTimeout(this.verificationId);
      },
      forceResendingToken: resendToken,
    );
  }
}

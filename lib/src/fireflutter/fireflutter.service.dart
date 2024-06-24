import 'package:flutter/material.dart';

class FireFlutterService {
  static FireFlutterService? _instance;
  static FireFlutterService get instance =>
      _instance ??= FireFlutterService._();

  FireFlutterService._();

  /// Global BuildContext
  ///
  /// 상위 앱의 global build context 를 사용하게 할 때 사용한다.
  /// 즉, [globalContext] 를 지정하면, 상위 앱의 global build context 를 사용하는데, 이렇게하면,
  /// FireFlutter 에서 사용하는 snackbar 나 기타 UI 의 context 들이 앱의 global context 와
  /// 일치하여,
  BuildContext Function()? _globalContext;
  BuildContext? get globalContext => _globalContext?.call();

  /// Set the region of the callable function.
  ///
  /// To call callable function in Firebase cloud functions, you need to set the region.
  ///
  /// This is used when the user resigns and deletes the user data. You may not need to set this,
  /// if you don't use the resign function or any callable functions.

  String? cloudFunctionRegion;

  /// Set the toastBackgroundColor to give color on fireflutter toast background color
  Color? toastBackgroundColor;

  // set the toastForegroundColor to give color on fireflutter toast foreground color
  Color? toastForegroundColor;

  /// Confirm Dialog this callback is used to customize all the confirm functions
  /// in fireflutter see `lib/fireflutter.functions.dart`
  Future<bool?> Function({
    required BuildContext context,
    required String? title,
    required String message,
  })? confirmDialog;

  /// Error Dialog this callback is used to customize all the error functions in
  /// fireflutter see `lib/fireflutter.functions.dart`
  Future<bool?> Function({
    required BuildContext context,
    required String? title,
    required String message,
  })? errorDialog;

  /// Alert Dialog this callback is use to customize the alert functions in fireflutter
  /// see `lib/fireflutter.functions.dart`
  Future<void> Function({
    required BuildContext context,
    required String? title,
    required String message,
  })? alertDialog;

  /// Input Dialog this callback is used to customize all the input functions
  /// in fireflutter. see `lib/fireflutter.functions.dart`
  Future<String?> Function({
    required BuildContext context,
    required String title,
    required String? subtitle,
    required String hintText,
    required String? initialValue,
    required int? minLines,
    required int? maxLines,
  })? inputDialog;

  init({
    String? cloudFunctionRegion,
    Color? toastBackgroundColor,
    Color? toastForegroundColor,
    BuildContext Function()? globalContext,
    Future<bool?> Function({
      required BuildContext context,
      required String? title,
      required String message,
    })? confirmDialog,
    Future<bool?> Function({
      required BuildContext context,
      required String? title,
      required String message,
    })? errorDialog,
    Future<void> Function({
      required BuildContext context,
      required String? title,
      required String message,
    })? alertDialog,
    Future<String?> Function({
      required BuildContext context,
      required String title,
      required String? subtitle,
      required String hintText,
      required String? initialValue,
      required int? minLines,
      required int? maxLines,
    })? inputDialog,
  }) {
    _globalContext = globalContext;
    this.toastBackgroundColor = toastBackgroundColor;
    this.toastForegroundColor = toastForegroundColor;
    this.cloudFunctionRegion = cloudFunctionRegion;
    this.confirmDialog = confirmDialog;
    this.errorDialog = errorDialog;
    this.alertDialog = alertDialog;
    this.inputDialog = inputDialog;
  }
}

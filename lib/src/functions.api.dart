import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fireflutter/fireflutter.dart';

/// FunctionsApi
///
/// See README.md for details.
class FunctionsApi {
  static FunctionsApi? _instance;
  static FunctionsApi get instance {
    _instance ??= FunctionsApi();
    return _instance!;
  }

  String serverUrl = '';

  init({
    required String serverUrl,
    // required Function(String) onError,
  }) {
    // print('FunctionsApi::init');
    this.serverUrl = serverUrl;
    // this.onError = onError;
  }

  /// Request and return the data.
  ///
  /// See details in README.md
  Future request(
    String functionName, {
    Map<String, dynamic>? data,
  }) async {
    if (data == null) data = {};
    final dio = getRetryDio();

    /// Debug URL
    // logUrl(functionName, data);

    /// EO Debug URL

    try {
      final res = await dio.post(
        FunctionsApi.instance.serverUrl + functionName,
        data: data,
      );

      /// If the response is a string and begins with `ERROR_`, then it is an error.
      if (res.data is String && (res.data as String).startsWith('ERROR_')) {
        throw res.data;
      } else

      /// If the response is an Map(object) and has a non-empty value of `code` property, then it is considered as an error.
      if (res.data is Map && res.data['code'] != null && res.data['code'] != '') {
        throw res.data['code'];
      } else

      /// If the response is a JSON string and has `code` property and `ERR_` string, then it is firebase error.
      if (res.data is String && (res.data as String).contains('code') && (res.data as String).contains('ERR_')) {
        throw res.data;
      } else {
        /// success
        return res.data;
      }
    } catch (e) {
      /// Dio error
      if (e is DioError) {
        logUrl(functionName, data);
        throw e.message;
      } else {
        /// Unknown error
        logUrl(functionName, data);
        rethrow;
      }
    }
  }

  /// 호출하는 URL 정보를 콘솔 로그로 출력
  logUrl(String functionName, dynamic data) {
    Map<String, dynamic> temp = Map<String, dynamic>.from(data);
    for (final k in temp.keys) {
      if (temp[k] != null && !(temp[k] is String) && !(temp[k] is List) && !(temp[k] is Map)) {
        temp[k] = data[k].toString();
      }
    }
    final httpsUri = Uri(queryParameters: temp);
    log(FunctionsApi.instance.serverUrl + functionName + httpsUri.toString());
  }

  /// 전화 번호가 가입되어져 있는지 확인.
  ///
  /// 입력된 전화번호가 이미 가입되어져 있으면 참을 리턴.
  /// 전화번호 로그인을 할 때, Anonymous 계정과 합치기 위해 이미 가입된 전화번호를 확인하는데 사용된다.
  /// 참고로, 이 기능은 반드시, cloud function 으로 작업을 해야만 한다.
  Future<bool> phoneNumberExists(String phoneNumber) async {
    // final res = await FunctionsApi.instance.request(
    //   FunctionName.getUserUidFromPhoneNumber,
    //   data: {'phoneNumber': phoneNumber},
    // );
    final res = await this.getUserUidFromPhoneNumber(phoneNumber);
    print('---------> res; $res');
    return res['uid'] != '';
  }

  Future getUserUidFromPhoneNumber(String phoneNumber) {
    return FunctionsApi.instance.request(
      FunctionName.getUserUidFromPhoneNumber,
      data: {'phoneNumber': phoneNumber},
    );
  }
}

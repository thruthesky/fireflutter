class FireFlutterException implements Exception {
  final String code;
  final String message;

  FireFlutterException(this.code, this.message);

  @override
  String toString() {
    return 'FireFlutterException: ($code) $message';
  }
}

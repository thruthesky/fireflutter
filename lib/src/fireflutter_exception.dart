class FireFlutterException implements Exception {
  final String code;
  final String message;

  FireFlutterException({required this.code, required this.message});

  @override
  String toString() {
    return 'FireFlutterException{code: $code, message: $message}';
  }
}

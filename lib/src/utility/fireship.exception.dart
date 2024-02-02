class FireshipException implements Exception {
  final String code;
  final String message;

  FireshipException(this.code, this.message);

  @override
  String toString() {
    return 'FireshipException: ($code) $message';
  }
}

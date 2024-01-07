class Issue implements Exception {
  String code;
  String? message;
  Issue(this.code, [this.message]);

  @override
  String toString() {
    return "--> Issue: [$code] : $message";
  }
}

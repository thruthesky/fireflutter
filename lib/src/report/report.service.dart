import 'package:fireship/fireship.dart';

class ReportService {
  static ReportService get instance => _instance ??= ReportService._();
  static ReportService? _instance;
  ReportService._() {
    dog('--> ReportService._()');
  }
  Future<void> report({
    required String otherUserUid,
    String reason = '',
  }) async {
    if (notLoggedIn) {
      throw Issue(Code.notLoggedIn);
    }
    await ReportModel.create(otherUserUid: otherUserUid, reason: reason);
  }
}

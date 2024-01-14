import 'package:fireship/fireship.dart';

class ReportService {
  static ReportService get instance => _instance ??= ReportService._();
  static ReportService? _instance;
  ReportService._() {
    dog('--> ReportService._()');
  }
  Future<void> report({
    String? otherUserUid,
    String? chatRoomId,
    String? postId,
    String? commentId,
    String reason = '',
  }) async {
    if (notLoggedIn) {
      throw Issue(Code.notLoggedIn);
    }
    await ReportModel.create(
      otherUserUid: otherUserUid,
      chatRoomId: chatRoomId,
      postId: postId,
      commentId: commentId,
      reason: reason,
    );
  }
}

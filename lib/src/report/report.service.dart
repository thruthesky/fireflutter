import 'package:fireship/fireship.dart';

class ReportService {
  static ReportService get instance => _instance ??= ReportService._();
  static ReportService? _instance;
  ReportService._() {
    dog('--> ReportService._()');
  }

  @Deprecated('Use ReportModel.create instead')
  Future<void> report({
    String? otherUserUid,
    String? chatRoomId,
    String? category,
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
      category: category,
      postId: postId,
      commentId: commentId,
      reason: reason,
    );
  }
}

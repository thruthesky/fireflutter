/// Gets the sort sortString string
///
/// [sortString] is the sort string. It must come from the parent's comment.
///
/// [depth] is the depth of the comment. Just pass the parent's depth as it is.
/// No need to +1 before passing to this function.
/// Instead, you must save the depth of the new comment by adding +1 on the
/// depth of parent comment when it is being created.
///
/// [noOfComments] is the number of comments of the post. It must come from the post.
///
/// example
/// ```dart
/// FirebaseFirestore.instance.collection('comments').add({
///     'sort': getCommentSortString(noOfComments: post.noOfComments, depth: parent?.depth ?? 0, sortString: parentComment?.sort),
///     'depth': parent == null ? 1 : parent.depth + 1,
/// });
/// ```
String getCommentSortString({
  required int depth,
  int? noOfComments,
  String? sortString,
}) {
  /// depth and maxDepth must not be more than 9
  const int maxDepth = 9;

  /// 맨 첫 번째 코멘트란, 글에 최초로 작성되는 코멘트. 1번째 코멘트. 해당 글에 하나 뿐.
  /// 첫번째 레벨 코멘트란, 글 바로 아래에 작성되는 코멘트로, 부모 코멘트가 없는 코멘트이다. 이 경우 depth=0 이다.
  /// noOfComments 는 글의 noOfComments 이다. 참고, 맨 첫번째 코멘트를 작성할 때는 noOfComments 값을 그냥 0의 값(또는 NULL)을 입력하면 된다.
  /// [sortString] 는 부모 코멘트의 sortString string 이다. 첫번째 레벨 코멘트의 경우, 빈 NULL (또는 빈문자열)을 입력하면 된다.
  /// [depth] 는 부모 코멘트의 depth 이다. depth 를 부모의 것을 그대로 입력하면 된다. 함수로 전달하기 전에 +1 을 할 필요 없다.
  /// ( 예: 부모 코멘트가 존재하면, 부모의 것을(기본 값은 0) 아니면, 글의 것을 사용(기본 값은 0) )
  /// 참고, 여기서 depth 는 sortString 구분 문자열의 칸을 말하는 것으로, 그냥 부모의 depth 만 그대로 입력하면 된다.
  /// 단, 새로운 코멘트를 저장 할 때에는 부모 depth 에 +1 을 해서 저장해야 한다.
  noOfComments ??= 0;
  sortString ??= "";
  if (sortString == "" || depth == 0) {
    final firstPart = 100000 + noOfComments;
    return '$firstPart.100000.100000.100000.100000.100000.100000.100000.100000.100000';
  } else {
    if (depth > maxDepth) depth = maxDepth;
    List<String> parts = sortString.split('.');
    String block = parts[depth];
    int computed =
        int.parse(block) + noOfComments + 1; // 처음이 0일 수 있다. 0이면, 부모와 같아서 안됨.
    parts[depth] = computed.toString();
    sortString = parts.join('.');
    return sortString;
  }
}

/// Used to collect all the last comments' sort on each depth
/// Map<String, String>
///
/// ===> The first generic [String] is the parent's id,
///       it means the ID of the parent of its last child comment.
///       If it's null, it means it is from parent comments
///       (a.k.a root comments or comments directly commented
///       under the post).
///
/// ===> The second generic [String] is the last comment's sort under
///       the parent String (based from the first generic String - parentId).
typedef LastChildCommentSort = Map<String?, String>;

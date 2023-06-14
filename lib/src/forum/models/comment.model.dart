class CommentModel {
  final String id;
  final String content;
  final int createdAt;
  final int depth;
  final String parentId;
  final String postId;
  final String sort;
  final String uid;
  final int updatedAt;

  const CommentModel(
      {required this.id,
      required this.content,
      required this.createdAt,
      required this.depth,
      required this.parentId,
      required this.postId,
      required this.sort,
      required this.uid,
      required this.updatedAt});

  factory CommentModel.fromJson(String id, Map<String, dynamic> json) {
    return CommentModel(
        id: id,
        content: json["content"],
        createdAt: json["createdAt"],
        depth: json["depth"],
        parentId: json["parentId"],
        postId: json["postId"],
        sort: json["sort"],
        uid: json["uid"],
        updatedAt: json["updatedAt"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "content": content,
      "createdAt": createdAt,
      "depth": depth,
      "parentId": parentId,
      "postId": postId,
      "sort": sort,
      "uid": uid,
      "updatedAt": updatedAt
    };
  }
}

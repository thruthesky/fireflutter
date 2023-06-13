class PhotoUploadResult {
  final Map<String, dynamic> result;
  final Map<String, dynamic> response;
  final String url;

  PhotoUploadResult({required this.result, required this.response, required this.url});

  factory PhotoUploadResult.fromJson(Map<String, dynamic> json) {
    return PhotoUploadResult(response: json['response'], result: json['request'], url: json['response']['url']);
  }
}

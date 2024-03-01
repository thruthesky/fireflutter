import 'package:fireflutter/fireflutter.dart';

/// These are the hit from `hits` in Search Result Model

class SearchResultHit {
  final SearchResultDoc document;
  final Map highlight;
  final List highlights;

  /// text_match
  final int textMatch;

  /// text_match_info
  final Map textMatchInfo;

  SearchResultHit({
    required this.document,
    required this.highlight,
    required this.highlights,
    required this.textMatch,
    required this.textMatchInfo,
  });

  factory SearchResultHit.fromJson(Map<String, dynamic> json) {
    return SearchResultHit(
      document: SearchResultDoc.fromJson(json['document']),
      highlight: json['highlight'],
      highlights: json['highlights'],
      textMatch: json['text_match'],
      textMatchInfo: json['text_match_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document': document.toJson(),
      'highlight': highlight,
      'highlights': highlights,
      'text_match': textMatch,
      'text_match_info': textMatchInfo,
    };
  }

  @override
  String toString() => toJson().toString();
}

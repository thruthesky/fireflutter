import 'package:fireship/fireship.dart';

/// # Search Result
/// This is needed to prevent typing error in Search result
/// with Typesense
///
/// This is directly the search result from typesense,
/// get the resulting docs in hits. (Using `SearchResultDoc` Model)
class SearchResult {
  /// facet_counts
  final List? facetCounts;
  final int? found;
  final List<SearchResultHit> hits;

  /// out_of
  final int? outOf;
  final int? page;

  /// request_params
  final Map? requestParams;

  /// search_cutoff
  final bool? searchCutoff;

  /// search_time_ms
  final int? searchTimeMs;

  SearchResult({
    required this.facetCounts,
    required this.found,
    required this.hits,
    required this.outOf,
    required this.page,
    required this.requestParams,
    required this.searchCutoff,
    required this.searchTimeMs,
  });

  factory SearchResult.fromJson(Map<dynamic, dynamic> json) {
    final hitsMap = json['hits'] == null
        ? []
        : List<Map<String, dynamic>>.from(json['hits']);
    final hits = hitsMap.map((e) => SearchResultHit.fromJson((e))).toList();
    return SearchResult(
      facetCounts: json['facet_counts'],
      found: json['found'],
      hits: hits,
      outOf: json['out_of'],
      page: json['page'],
      requestParams: json['request_params'],
      searchCutoff: json['search_cutoff'],
      searchTimeMs: json['search_time_ms'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facet_counts': facetCounts,
      'found': found,
      'hits': hits.map((e) => e.toJson()).toList(),
      'out_of': outOf,
      'page': page,
      'request_params': requestParams,
      'search_cutoff': searchCutoff,
      'search_time_ms': searchTimeMs,
    };
  }

  List<SearchResultDoc> get getDocs {
    return hits.map((e) => e.document).toList();
  }

  @override
  String toString() => toJson().toString();
}

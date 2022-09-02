import 'package:fireflutter/fireflutter.dart';

class TypesenseCollection {
  TypesenseCollection({
    this.data,
    required this.createdAt,
    required this.defaultSortingField,
    required this.fields,
    required this.name,
    required this.numDocument,
  });

  final dynamic data;

  final int createdAt;
  final String defaultSortingField;
  final List<dynamic> fields;
  final String name;
  final int numDocument;
  // symbols_to_index
  // token_separators

  factory TypesenseCollection.fromJSON(Json data) {
    return TypesenseCollection(
      data: data,
      name: data['name'],
      createdAt: data['created_at'],
      defaultSortingField: data['default_sorting_field'],
      fields: data['fields'],
      numDocument: data['num_documents'],
    );
  }

  @override
  String toString() {
    return '''TypeSense Collection: ($data)''';
  }
}

/// Typesense search options.
class TypesenseForumSearchOptionModel {
  /// [searchKey] - Search string.
  String searchKey = '*';

  /// [collectionName] - Document collection index to get data from.
  String collectionName = '';

  /// [page] - Current page number to fetch.
  int page = 1;

  /// [perPage] - Maximum number of documents to fetch.
  int perPage = 20;

  /// [queryBy] - Add filter for specific data property (e.g. post's title and content). ex: ['title', 'content'].
  List<String> queryBy = [];

  /// [filterBy] - Add filter for specific data property (e.g. post's hasPhoto and Gender). ex: ['gender:=M', 'hasPhoto:true'].
  List<String> filterBy = [];

  /// [sortBy] - Sort filter, up to 3 sort filters can be added. ex ['createdAt:asc', 'id:desc'].
  List<String> sortBy = ['createdAt:desc'];

  /// [category] - Filter forum content search with category.
  String category = '';

  /// [uid] - Filter forum content search with uid.
  String uid = '';
}

class TypesenseSearchResult {
  TypesenseSearchResult({
    required this.facetCounts,
    required this.found,
    required this.outOf,
    required this.page,
    required this.requestParams,
    required this.searchTimeMs,
    required this.hits,
  });

  final List<dynamic> facetCounts;

  /// Total number of items that matched with the query.
  final int found;

  /// total number of page.
  final int outOf;

  /// current page.
  final int page;

  final Map<String, dynamic> requestParams;
  final int searchTimeMs;

  final List<TypesenseSearchHitModel> hits;

  factory TypesenseSearchResult.fromJSON(Json json) {
    return TypesenseSearchResult(
      facetCounts: json['facet_counts'],
      found: json['found'],
      outOf: json['out_of'],
      page: json['page'],
      requestParams: json['request_params'],
      searchTimeMs: json['search_time_ms'],
      hits: json['hits']
          .map<TypesenseSearchHitModel>((e) => TypesenseSearchHitModel.fromJSON(e))
          .toList(),
    );
  }
}

class TypesenseSearchHitModel {
  TypesenseSearchHitModel({
    required this.highlights,
    required this.document,
    required this.textMatch,
  });

  final List<dynamic> highlights;
  final Map<String, dynamic> document;
  final int textMatch;

  factory TypesenseSearchHitModel.fromJSON(dynamic data) {
    return TypesenseSearchHitModel(
      highlights: data['highlights'],
      document: data['document'],
      textMatch: data['text_match'],
    );
  }
}

/// Typesense user search options.
class TypesenseUserSearchOptionModel {
  /// [searchKey] - Search string.
  String searchKey = '*';

  /// [collectionName] - Document collection index to get data from.
  String collectionName = '';

  /// [page] - Current page number to fetch.
  int page = 1;

  /// [perPage] - Maximum number of documents to fetch.
  int perPage = 20;

  /// [queryBy] - Add filter for specific data property (e.g. user's firstName and lastName). ex: ['firstName', 'lastName'].
  List<String> queryBy = [];

  /// [filterBy] - Add filter for specific data property (e.g. userr's hasPhotoUrl and Gender). ex: ['gender:=M', 'hasPhoto:true'].
  List<String> filterBy = [];

  /// [sortBy] - Sort filter, up to 3 sort filters can be added. ex ['registeredAt:asc', 'id:desc'].
  List<String> sortBy = ['registeredAt:desc'];

  /// [id] - filter id
  String id = '';
}

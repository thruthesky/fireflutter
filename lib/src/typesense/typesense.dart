import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import './typesense.model.dart';

class Typesense {
  static Typesense? _instance;
  static Typesense get instance {
    if (_instance == null) {
      _instance = Typesense();
    }
    return _instance!;
  }

  late String _serverUrl;
  late String _collectionPrefix;
  String? _apiKey;

  init(
      {required String serverUrl,
      required String collectionPrefix,
      String? apiKey}) {
    _serverUrl = serverUrl;
    _collectionPrefix = collectionPrefix.endsWith('_')
        ? collectionPrefix
        : collectionPrefix + '_';
    _apiKey = apiKey;
  }

  Future<TypesenseSearchResult> _search(String requestUrl) async {
    final res = await Dio().get(
      requestUrl,
      options: Options(
        headers: {
          "X-TYPESENSE-API-KEY": _apiKey,
        },
        validateStatus: (status) {
          return (status ?? 0) < 500;
        },
      ),
    );
    // debugPrint(res.data.toString());
    if (res.statusCode! > 299) {
      throw res.data.toString();
    }
    return TypesenseSearchResult.fromJSON(res.data);
  }

  /// Get typesense index collections
  ///
  Future<List<TypesenseCollection>> getCollections() async {
    final res = await Dio().get(
      '$_serverUrl/collections',
      options: Options(
        headers: {
          "X-TYPESENSE-API-KEY": _apiKey,
        },
        validateStatus: (status) {
          return (status ?? 0) < 500;
        },
      ),
    );

    final data = List<Map<String, dynamic>>.from(res.data)
        .where((element) => "${element['name']}".startsWith(_collectionPrefix))
        .map((data) => TypesenseCollection.fromJSON(data))
        .toList();
    return data;
  }

  /// Forum collection search
  ///
  Future<TypesenseSearchResult> forumSearch(
      TypesenseForumSearchOptionModel options) async {
    String requestUrl =
        '$_serverUrl/collections/$_collectionPrefix${options.collectionName}/documents/search?q=${options.searchKey}';

    final List<String> filters = [...options.filterBy];

    if (options.uid.isNotEmpty) {
      filters.add('uid:=${options.uid}');
    }

    if (options.category.isNotEmpty) {
      filters.add('category:=${options.category}');
    }

    if (filters.isNotEmpty) {
      requestUrl += '&filter_by=${filters.join(' && ')}';
    }

    if (options.queryBy.isNotEmpty) {
      requestUrl += '&query_by=${options.queryBy.join(",")}';
    }

    requestUrl += '&page=${options.page}&per_page=${options.perPage}';
    requestUrl += '&sort_by=${options.sortBy.join(", ")}&num_typos=0';

    // debugPrint(requestUrl);
    return _search(requestUrl);
  }

  /// User collection search
  ///
  Future<TypesenseSearchResult> userSearch(
      TypesenseUserSearchOptionModel options) async {
    String requestUrl =
        '$_serverUrl/collections/${_collectionPrefix}users/documents/search?q=${options.searchKey}';

    final filter = options.filterBy;
    if (options.id.isNotEmpty) {
      filter.add('id:${options.id}');
    }

    if (options.queryBy.isNotEmpty) {
      requestUrl += '&query_by=${options.queryBy.join(",")}';
    }
    if (options.filterBy.isNotEmpty) {
      requestUrl += '&filter_by=${options.filterBy.join("&&")}';
    }

    requestUrl += '&page=${options.page}&per_page=${options.perPage}';

    requestUrl += '&sort_by=${options.sortBy.join(",")}';

    // requestUrl += '&num_typos=0';

    // debugPrint(requestUrl);
    return _search(requestUrl);
  }

  Future<int> count({
    required String uid,
    List<String> filters = const [],
    String collectionName = 'posts',
  }) async {
    String url =
        '$_serverUrl/collections/$_collectionPrefix$collectionName/documents/search?q=*&';

    if (filters.isNotEmpty) {
      filters.insert(0, "filter_by=uid:=$uid");
      url += filters.join(" && ");
    } else {
      url += "filter_by=uid:=$uid";
    }

    debugPrint(url);
    final res = await _search(url);

    return res.found;
  }
}

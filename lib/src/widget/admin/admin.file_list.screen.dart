import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminFileListScreen extends StatefulWidget {
  const AdminFileListScreen({super.key, this.onTap});

  final Function(PhotoFileData)? onTap;

  @override
  State<AdminFileListScreen> createState() => _AdminFileListScreenState();
}

class _AdminFileListScreenState extends State<AdminFileListScreen> {
  int perPage = 5;
  bool isLastPage = false;
  String? pageToken;

  TextEditingController searchFieldController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final PagingController<int, Map<String, dynamic>> _pagingController = PagingController(firstPageKey: 0);

  final storageRef = FirebaseStorage.instance.ref().child("users");
  Reference photoRef(String uid) => FirebaseStorage.instance.ref().child("users/$uid");

  Reference getFile(String path) => FirebaseStorage.instance.ref().child(path);

  Future<String> getFileUrl(String path) => getFile(path).getDownloadURL();
  Future<FullMetadata> getFileMetaData(String path) => getFile(path).getMetadata();

  Future<Map<String, dynamic>> getUploadData(String uid) async {
    return {
      "uid": uid,
      "list": await photoRef(uid).listAll(),
    };
  }

  Future<Map<String, dynamic>> getFileData(String path, String uid) async {
    return {"uid": uid, "url": await getFileUrl(path), "customMetadata": (await getFileMetaData(path)).customMetadata};
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    final newItems = await getPhotos();

    if (isLastPage) {
      if (mounted) _pagingController.appendLastPage(newItems);
    } else {
      final nextPageKey = pageKey + newItems.length;
      if (mounted) _pagingController.appendPage(newItems, nextPageKey);
    }
  }

  resetAndSearch() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
    if (mounted) {
      setState(() {
        pageToken = null;
        isLastPage = false;
        _pagingController.refresh();
      });
    }
  }

  Future<List<Map<String, dynamic>>> getPhotos() async {
    if (searchFieldController.text.isNotEmpty) {
      isLastPage = true;
      return getUserPhotos(searchFieldController.text);
    }

    final ListResult usersListResult = await storageRef.list(ListOptions(
      maxResults: perPage,
      pageToken: pageToken,
    ));

    pageToken = usersListResult.nextPageToken;
    if (pageToken == null) isLastPage = true;

    return getItems(usersListResult);
  }

  Future<List<Map<String, dynamic>>> getUserPhotos(String uid) async {
    ListResult uploadListResult = await photoRef(uid).listAll();
    List<Future<Map<String, dynamic>>> uploadsListFuture = [];
    for (final item in uploadListResult.items) {
      uploadsListFuture.add(getFileData(item.fullPath, uid));
    }
    return Future.wait(uploadsListFuture);
  }

  Future<List<Map<String, dynamic>>> getItems(ListResult userList) async {
    List<Future<Map<String, dynamic>>> userListFuture = [];
    for (final prefix in userList.prefixes) {
      userListFuture.add(getUploadData(prefix.name));
    }

    List<Map<String, dynamic>> usersFutures = await Future.wait(userListFuture);
    List<Future<Map<String, dynamic>>> uploadsListFuture = [];
    for (final user in usersFutures) {
      ListResult uploadListResult = user['list'] as ListResult;
      for (final item in uploadListResult.items) {
        uploadsListFuture.add(getFileData(item.fullPath, user['uid']));
      }
    }
    return Future.wait(uploadsListFuture);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('AdminUserList'),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(8, 16, 8, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchFieldController,
                      decoration: const InputDecoration(
                        hintText: 'Enter uid',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onSubmitted: (text) => resetAndSearch(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      resetAndSearch();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: PagedGridView(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                scrollController: _scrollController,
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<dynamic>(
                  itemBuilder: (context, item, index) {
                    final photo = PhotoFileData.fromJSON(item);
                    return GestureDetector(
                      onTap: () {
                        widget.onTap?.call(photo);
                      },
                      child: CachedNetworkImage(
                        imageUrl: photo.url,
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 6.0,
                  mainAxisSpacing: 6.0,
                ),
              ),
            ),
          ],
        ));
  }
}

class PhotoFileData {
  PhotoFileData({
    required this.userDocumentReference,
    required this.url,
    // this.customMetaData,
  });

  String userDocumentReference;
  String url;
  // CustomMetaData? customMetaData;

  factory PhotoFileData.fromJSON(Map<String, dynamic> json) {
    return PhotoFileData(
      userDocumentReference: json['userDocumentReference'] ?? '',
      url: json['url'] ?? '',
      // customMetaData: CustomMetaData.fromJSON(json['customMetaData'] ?? {}),
    );
  }
}

import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// PostListView
///
/// This supports most of the parameters of ListView
class PostListView extends StatelessWidget {
  const PostListView({
    super.key,
    required this.category,
    this.pageSize = 10,
    this.loadingBuilder,
    this.errorBuilder,
    this.separatorBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,

    ///
    this.gridView = false,
  });

  final String category;

  final int pageSize;
  final Widget Function()? loadingBuilder;
  final Widget Function(String)? errorBuilder;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  /// GridView options
  final bool gridView;

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseQueryBuilder(
      query: Post.postSummariesRef.child(category).orderByChild(Field.order),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return loadingBuilder?.call() ??
              const Center(child: CircularProgressIndicator.adaptive());
        }

        if (snapshot.hasError) {
          dog('Error: ${snapshot.error}');
          return errorBuilder?.call(snapshot.error.toString()) ??
              Text('Something went wrong! ${snapshot.error}');
        }

        return gridView
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                scrollDirection: scrollDirection,
                reverse: reverse,
                controller: controller,
                primary: primary,
                physics: physics,
                shrinkWrap: shrinkWrap,
                padding: padding,
                addAutomaticKeepAlives: addAutomaticKeepAlives,
                addRepaintBoundaries: addRepaintBoundaries,
                addSemanticIndexes: addSemanticIndexes,
                cacheExtent: cacheExtent,
                dragStartBehavior: dragStartBehavior,
                keyboardDismissBehavior: keyboardDismissBehavior,
                restorationId: restorationId,
                clipBehavior: clipBehavior,
                itemCount: snapshot.docs.length,
                itemBuilder: (context, index) {
                  // if we reached the end of the currently obtained items, we try to
                  // obtain more items
                  if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                    // Tell FirebaseDatabaseQueryBuilder to try to obtain more items.
                    // It is safe to call this function from within the build method.
                    snapshot.fetchMore();
                  }

                  final post = Post.fromSnapshot(snapshot.docs[index]);

                  return Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.teal[100],
                    child: Text("User name is ${post.title}"),
                  );
                },
              )
            : ListView.separated(
                itemCount: snapshot.docs.length,
                separatorBuilder: (context, index) =>
                    separatorBuilder?.call(context, index) ??
                    const SizedBox.shrink(),
                scrollDirection: scrollDirection,
                reverse: reverse,
                controller: controller,
                primary: primary,
                physics: physics,
                shrinkWrap: shrinkWrap,
                padding: padding,
                addAutomaticKeepAlives: addAutomaticKeepAlives,
                addRepaintBoundaries: addRepaintBoundaries,
                addSemanticIndexes: addSemanticIndexes,
                cacheExtent: cacheExtent,
                dragStartBehavior: dragStartBehavior,
                keyboardDismissBehavior: keyboardDismissBehavior,
                restorationId: restorationId,
                clipBehavior: clipBehavior,
                itemBuilder: (context, index) {
                  // if we reached the end of the currently obtained items, we try to
                  // obtain more items
                  if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                    // Tell FirebaseDatabaseQueryBuilder to try to obtain more items.
                    // It is safe to call this function from within the build method.
                    snapshot.fetchMore();
                  }

                  final post = Post.fromSnapshot(snapshot.docs[index]);
                  if (post.deleted) {
                    return const SizedBox.shrink();
                  }
                  return PostListTile(
                    post: post,
                  );
                },
              );
      },
    );
  }

  PostListView.gridView({
    Key? key,
    required String category,
    int pageSize = 20,
    Widget Function()? loadingBuilder,
    Widget Function(String)? errorBuilder,
    Widget Function(BuildContext, int)? separatorBuilder,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
  }) : this(
          category: category,
          gridView: true,
          scrollDirection: scrollDirection,
          padding: const EdgeInsets.all(8),
          shrinkWrap: shrinkWrap,
          primary: primary,
          controller: controller,
          physics: physics,
          reverse: reverse,
          separatorBuilder: separatorBuilder,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          pageSize: pageSize,
          key: key,
          clipBehavior: clipBehavior,
          restorationId: restorationId,
          dragStartBehavior: dragStartBehavior,
          cacheExtent: cacheExtent,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          keyboardDismissBehavior: keyboardDismissBehavior,
        );
}

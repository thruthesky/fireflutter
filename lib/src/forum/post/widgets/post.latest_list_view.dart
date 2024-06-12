import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

import 'package:flutter/gestures.dart';

/// PostLatestListView
///
/// This supports most of the parameters of ListView
/// StreamBuilder 위젯으로 가장 최근의 몇 개 글을 가져와 화면에 보여준다.
class PostLatestListView extends StatelessWidget {
  const PostLatestListView({
    super.key,
    this.category,
    this.group,
    this.limit = 5,
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
    this.itemBuilder,
    this.emptyBuilder,

    ///
    this.gridView = false,
    this.gridDelegate,
  });

  final String? category;
  final String? group;

  final int limit;
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
  final Widget Function(Post, int)? itemBuilder;
  final Widget Function()? emptyBuilder;

  /// GridView options
  final bool gridView;
  final SliverGridDelegate? gridDelegate;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: Post.latestSummary(
        category: category,
        group: group,
        limit: limit,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call() ??
              const Center(child: CircularProgressIndicator.adaptive());
        }

        if (snapshot.hasError) {
          dog('Error: ${snapshot.error}');
          return errorBuilder?.call(snapshot.error.toString()) ??
              Text('Something went wrong! ${snapshot.error}');
        }

        final List<Post>? posts = snapshot.data;

        if (posts == null || posts.isEmpty) {
          return emptyBuilder?.call() ??
              Center(child: Text(T.postEmptyList.tr));
        }

        return gridView
            ? GridView.builder(
                gridDelegate: gridDelegate ??
                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];

                  return itemBuilder?.call(post, index) ?? PostCard(post: post);
                },
              )
            : ListView.separated(
                itemCount: posts.length,
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
                  final post = posts[index];

                  return itemBuilder?.call(post, index) ??
                      PostListTile(
                        post: post,
                      );
                },
              );
      },
    );
  }

  PostLatestListView.gridView({
    Key? key,
    required String category,
    int limit = 6,
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
    Widget Function(Post, int)? itemBuilder,
    Widget Function()? emptyBuilder,
    SliverGridDelegate? gridDelegate,
  }) : this(
          category: category,
          gridView: true,
          scrollDirection: scrollDirection,
          padding: padding,
          shrinkWrap: shrinkWrap,
          primary: primary,
          controller: controller,
          physics: physics,
          reverse: reverse,
          separatorBuilder: separatorBuilder,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          limit: limit,
          key: key,
          clipBehavior: clipBehavior,
          restorationId: restorationId,
          dragStartBehavior: dragStartBehavior,
          cacheExtent: cacheExtent,
          addSemanticIndexes: addSemanticIndexes,
          addRepaintBoundaries: addRepaintBoundaries,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          keyboardDismissBehavior: keyboardDismissBehavior,
          itemBuilder: itemBuilder,
          emptyBuilder: emptyBuilder,
          gridDelegate: gridDelegate,
        );
}

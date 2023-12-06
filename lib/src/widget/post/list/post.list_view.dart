import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// PostListView
///
/// Dispaly posts in a list view.
class PostListView extends StatelessWidget {
  const PostListView({
    super.key,
    this.itemExtent,
    this.cacheExtent,
    this.itemBuilder,
    this.emptyBuilder,
    this.pageSize = 10,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    this.categoryId,
    this.uid,
    this.onTap,
    this.isCached = false,
  }) : assert(itemBuilder == null || onTap == null,
            'itemBuilder and onTap cannot be used together. Add onTap to the return Widget in itemBuilder instead.');

  final double? itemExtent;
  final double? cacheExtent;
  final int pageSize;
  final Widget Function(BuildContext, Post)? itemBuilder;
  final Widget Function(BuildContext)? emptyBuilder;
  final ScrollController? scrollController;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;
  final String? categoryId;
  final String? uid;
  final bool isCached;

  final Function(Post)? onTap;

  Query get query {
    Query q = postCol;
    if (categoryId != null) q = q.where('categoryId', isEqualTo: categoryId);
    if (uid != null) q = q.where('uid', isEqualTo: uid);
    return q.orderBy('createdAt', descending: true);
  }

  @override
  Widget build(BuildContext context) {
    // return FirestoreListView(
    //   itemExtent: itemExtent,
    //   cacheExtent: cacheExtent,
    //   query: query,
    //   itemBuilder: (context, QueryDocumentSnapshot snapshot) {
    //     final post = Post.fromDocumentSnapshot(snapshot);
    //     if (itemBuilder != null) return itemBuilder!(context, post);
    //     return ListTile(
    //       title: Text(post.title),
    //       subtitle: Text(
    //         post.content.replaceAll('\n', ' '),
    //         maxLines: 1,
    //         overflow: TextOverflow.ellipsis,
    //       ),
    //       trailing: const Icon(Icons.chevron_right),
    //       onTap: () {
    //         onTap?.call(post) ??
    //             PostService.instance.showPostViewScreen(
    //               context: context,
    //               post: post,
    //             );
    //       },
    //     );
    //   },
    //   emptyBuilder: (context) {
    //     if (emptyBuilder != null) return emptyBuilder!(context);
    //     return Center(child: Text(tr.noPost));
    //   },
    //   errorBuilder: (context, error, stackTrace) {
    //     log(error.toString(), stackTrace: stackTrace);
    //     return Center(child: Text('Error loading posts $error'));
    //   },
    //   pageSize: pageSize,
    //   controller: scrollController,
    //   primary: primary,
    //   physics: physics,
    //   shrinkWrap: shrinkWrap,
    //   padding: padding,
    //   dragStartBehavior: dragStartBehavior,
    //   keyboardDismissBehavior: keyboardDismissBehavior,
    //   clipBehavior: clipBehavior,
    // );

    // turn the FirestoreListView into FirestoreQueryBuilder
    // and add the cache
    return FirestoreQueryBuilder(
      query: query,
      builder: (context, snapshot, widgetResult) {
        // final post = Post.fromDocumentSnapshot(snapshot);
        // if (itemBuilder != null) return itemBuilder!(context, post);
        // return ListTile(
        //   title: Text(post.title),
        //   subtitle: Text(
        //     post.content.replaceAll('\n', ' '),
        //     maxLines: 1,
        //     overflow: TextOverflow.ellipsis,
        //   ),
        //   trailing: const Icon(Icons.chevron_right),
        //   onTap: () {
        //     onTap?.call(post) ??
        //         PostService.instance.showPostViewScreen(
        //           context: context,
        //           post: post,
        //         );
        //   },
        // );
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading posts ${snapshot.error}'));
        }

        return ListView.builder(
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            final post = Post.fromDocumentSnapshot(snapshot.docs[index]);
            if (itemBuilder != null) return itemBuilder!(context, post);
            return ListTile(
              title: Text(post.title),
              subtitle: Text(
                post.content.replaceAll('\n', ' '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                onTap?.call(post) ??
                    PostService.instance.showPostViewScreen(
                      context: context,
                      post: post,
                    );
              },
            );
          },
        );
      },
      // emptyBuilder: (context) {
      //   if (emptyBuilder != null) return emptyBuilder!(context);
      //   return Center(child: Text(tr.noPost));
      // },
      // errorBuilder: (context, error, stackTrace) {
      //   log(error.toString(), stackTrace: stackTrace);
      //   return Center(child: Text('Error loading posts $error'));
      // },
      // pageSize: pageSize,
      // controller: scrollController,
      // primary: primary,
      // physics: physics,
      // shrinkWrap: shrinkWrap,
      // padding: padding,
      // dragStartBehavior: dragStartBehavior,
      // keyboardDismissBehavior: keyboardDismissBehavior,
      // clipBehavior: clipBehavior,
      // isCached: isCached,
    );
  }
}

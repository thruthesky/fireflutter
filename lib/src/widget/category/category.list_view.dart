import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// CategoryListView
///
/// It uses [FirestoreListView] to show the list of categories which uses [ListView] internally.
/// And it supports some(not all) of the ListView properties.
class CategoryListView extends StatefulWidget {
  const CategoryListView({
    super.key,
    // required this.controller,
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
    this.onTap,
  });

  final int pageSize;
  final Widget Function(BuildContext, Category)? itemBuilder;
  final Widget Function(BuildContext)? emptyBuilder;
  final ScrollController? scrollController;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;
  final Function(Category category)? onTap;

  @override
  State<CategoryListView> createState() => CategoryListViewState();
}

class CategoryListViewState extends State<CategoryListView> {
  @override
  void initState() {
    super.initState();
    // widget.controller.state = this;
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreListView(
      query: CategoryService.instance.categoryCol,
      itemBuilder: (context, QueryDocumentSnapshot snapshot) {
        final category = Category.fromDocumentSnapshot(snapshot);
        if (widget.itemBuilder != null) {
          return widget.itemBuilder!(context, category);
        } else {
          return ListTile(
            title: Text(category.name),
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap!.call(category);
              } else {
                PostService.instance.showPostListDialog(context, category.id);
              }
            },
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category.description != null) Text(category.description!),
              ],
            ),
          );
        }
      },
      emptyBuilder: (context) {
        if (widget.emptyBuilder != null) {
          return widget.emptyBuilder!(context);
        } else {
          return Center(child: Text(tr.noCategory));
        }
      },
      errorBuilder: (context, error, stackTrace) {
        log(error.toString(), stackTrace: stackTrace);
        return Center(child: Text('Error loading categories $error'));
      },
      pageSize: widget.pageSize,
      controller: widget.scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      clipBehavior: widget.clipBehavior,
    );
  }
}

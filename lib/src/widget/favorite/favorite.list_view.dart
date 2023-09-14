import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Favorite List View
///
///
class FavoriteListView extends StatelessWidget {
  const FavoriteListView({
    super.key,
    this.type,
    this.pageSize = 10,
    this.shrinkWrap = false,
    this.physics,
    this.itemBuilder,
    this.itemExtent,
  });

  final int pageSize;

  final FavoriteType? type;

  final bool shrinkWrap;
  final ScrollPhysics? physics;

  final Widget Function(Favorite)? itemBuilder;
  final double? itemExtent;

  @override
  Widget build(BuildContext context) {
    return FirestoreListView(
      shrinkWrap: shrinkWrap,
      physics: physics,
      pageSize: pageSize,
      query: Favorite.query(type: type),
      itemExtent: itemExtent,
      itemBuilder: (context, doc) {
        final favorite = Favorite.fromDocumentSnapshot(doc);
        if (itemBuilder != null) return itemBuilder!(favorite);
        return Card(
          child: Column(
            children: [
              Text('type: ${favorite.type}'),
              ListTile(
                title: Text(favorite.id),
                subtitle: Text(favorite.createdAt.toString()),
              ),
            ],
          ),
        );
      },
    );
  }
}

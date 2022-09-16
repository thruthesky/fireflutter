import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutterfire_ui/firestore.dart';

/// 무한 스크롤을 통해서 한번에 주욱 다 보여준다.
class PointHistory extends StatelessWidget {
  const PointHistory({
    Key? key,
    required this.year,
    required this.month,
  }) : super(key: key);

  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    log('UserService.instance.pointHistoryCol.path: ${UserService.instance.pointHistoryCol.path}');
    return FirestoreListView<PointHistoryModel>(
        query: UserService.instance.pointHistoryCol
            .orderBy('createdAt', descending: true)
            .withConverter(
                fromFirestore: ((snapshot, _) =>
                    PointHistoryModel.fromJson(snapshot.data()!)),
                toFirestore: (history, _) => history.toJson()),
        errorBuilder: (context, error, stackTrace) => Text(error.toString()),
        itemBuilder: ((context, doc) {
          final history = doc.data();
          return ListTile(
            title: Text('${_text(history)} (${history.point})'),
            subtitle: ShortDate(history.createdAt.seconds),
          );
        }));
  }

  _text(PointHistoryModel history) {
    switch (history.eventName) {
      case EventName.postCreate:
        return 'Post creation';
      case EventName.commentCreate:
        return 'Comment creation';
      default:
        return history.eventName;
    }
  }
}

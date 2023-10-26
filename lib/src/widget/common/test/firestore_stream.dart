import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FirestoreStream extends StatefulWidget {
  const FirestoreStream({
    super.key,
    this.initialQuerySnapshot,
    required this.snapshots,
    required this.builder,
  });

  final QuerySnapshot<Object?>? initialQuerySnapshot;
  final Stream<QuerySnapshot<Object?>> snapshots;
  final Widget Function(BuildContext context, QuerySnapshot<Object?> snapshot) builder;

  @override
  FirestoreStreamState createState() => FirestoreStreamState();
}

class FirestoreStreamState extends State<FirestoreStream> {
  QuerySnapshot<Object?>? _snapshots;

  @override
  void initState() {
    super.initState();
    _snapshots = widget.initialQuerySnapshot;
    widget.snapshots.listen(
      (QuerySnapshot<Object?> event) {
        if (event.docs.isEmpty) return;
        setState(() {
          _snapshots = event;
        });
        dog("current data: ${event.docs}");
      },
      onError: (error) => dog("Listen failed: $error"),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_snapshots != null) {
      return widget.builder(context, _snapshots!);
    }
    return const Text('FirestoreStream');
  }
}

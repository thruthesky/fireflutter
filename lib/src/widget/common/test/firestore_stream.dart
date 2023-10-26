import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

// This should only be used as child of a FirebaseFirestoreQuery or else it will read all
// unless we limit the query
//
// Currently the side effect that I can think,
// When the docs has been modified (i.e. removed all the documents),
// the snapshot will show some records very quickly before it shows empty.
class FirestoreStream extends StatefulWidget {
  const FirestoreStream({
    super.key,
    // TODO There should have an ID to store the snapshot in the outside state variable
    this.initialQuerySnapshot,
    required this.snapshots,
    required this.builder,
    this.onSnapshot,
  });

  final QuerySnapshot<Object?>? initialQuerySnapshot;
  final Stream<QuerySnapshot<Object?>> snapshots;
  final Widget Function(BuildContext context, QuerySnapshot<Object?> snapshot) builder;
  final void Function(QuerySnapshot<Object?> snapshot)? onSnapshot;

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
        // TODO instead of calling onSnapshot, we should store the snapshot in the  outside state variable
        // It can be a Map<String, snapshot> where String is the ID of the snapshot
        widget.onSnapshot?.call(event);
        dog("current data: ${event.docs}");
      },
      onError: (error) => dog("Listen failed: $error"),
    );
  }

  // TODO on dispose, we should remove the snapshot from the outside state variable Map<String, snapshot>

  @override
  Widget build(BuildContext context) {
    if (_snapshots != null) {
      return widget.builder(context, _snapshots!);
    }
    return const Text('FirestoreStream');
  }
}

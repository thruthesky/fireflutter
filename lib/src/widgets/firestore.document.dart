import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Get a document(or the first document) from Firestore.
/// It listens and updates only if the document(or the query) updates,
/// So, there will be less flickering (compring to the StreamBuilder).
class FirestoreDocument extends StatefulWidget {
  const FirestoreDocument({
    Key? key,
    this.path,
    this.query,
    required this.onError,
    required this.onFound,
    required this.onNotFound,
  }) : super(key: key);

  final String? path;
  final Query? query;
  final Function(dynamic) onError;
  final Function(dynamic) onFound;
  final Function() onNotFound;

  @override
  State<FirestoreDocument> createState() => _FirestoreDocumentState();
}

class _FirestoreDocumentState extends State<FirestoreDocument> {
  dynamic data;
  bool notFound = false;
  dynamic error;

  StreamSubscription? sub;

  @override
  void initState() {
    super.initState();

    if (widget.path != null) {
      sub = FirebaseFirestore.instance.doc(widget.path!).snapshots().listen(
        (DocumentSnapshot snapshot) {
          if (snapshot.exists) {
            setState(() {
              data = snapshot.data();
            });
          } else {
            setState(() {
              data = null;
            });
          }
        },
        onError: (e) => setState(() => error = e),
      );
    } else {
      sub = widget.query!.snapshots().listen(
        (snapshot) {
          if (snapshot.size == 0)
            setState(() => data = null);
          else
            setState(() => data = snapshot.docs.first);
        },
        onError: (e) => setState(() => error = e),
      );
    }
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) return widget.onError(error);
    if (data == null) return widget.onNotFound();
    return widget.onFound(data);
  }
}

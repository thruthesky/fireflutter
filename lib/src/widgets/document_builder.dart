import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Get a document(or the first document) from Firestore.
/// It listens and updates only if the document(or the query) updates,
/// So, there will be less flickering (compring to the StreamBuilder).
class DocumentBuilder extends StatefulWidget {
  const DocumentBuilder({
    Key? key,
    this.path,
    this.query,
    required this.builder,
  }) : super(key: key);

  final String? path;
  final Query? query;
  final Widget Function(dynamic data) builder;

  @override
  State<DocumentBuilder> createState() => _DocumentBuilderState();
}

class _DocumentBuilderState extends State<DocumentBuilder> {
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
    if (error != null) {
      log('---> DocumentBuilder() error; path: ${widget.path}');
      log(error.toString());
      return Text(error.toString());
    }
    return widget.builder(data);
  }
}

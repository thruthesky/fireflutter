import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Listen to changes of a Firestore document and re-build the widget.
///
/// It listens and updates only if the document(or the query) updates,
/// So, there will be less flickering (compring to the StreamBuilder).
///
/// [path] is the path of the document.
/// [ref] is the firestore document reference of the document.
/// [query] is the Collection query, It will only listen the first document.
/// You may add `.limit(1)` on the query.
///
/// When the document does not exist, null will be passed as buider argument.
///
/// - ref example
/// ```dart
/// DocumentBuilder(
///   ref: FireFlutterService.instance.userSettingsDoc(uid, "chat.$uid"),
///   builder: (doc) {
///     if (doc == null) {
///       log('Document does not exist.');
///     }
///     return Icon(Icons.notifications);
///   });
/// ```
///
/// - Path example
/// ```dart
///   return DocumentBuilder(
///     path: "/party/${widget.party.id}/party-messaging-limits/today",
///     builder: (data) {
///       return Text("Sending Limit ... ${data}");
///     },
///    );
/// ```
///
/// - Query example
/// ```dart
///   return DocumentBuilder(
///     query: FirebaseFirestore.instanc.collection("/party/$partyId/party-attendees").where('uid', isEqualTo: uid).where('date', isEqualTo: date),
///     builder: builder,
///   );
/// ```
///
///
class DocumentBuilder extends StatefulWidget {
  const DocumentBuilder({
    Key? key,
    this.path,
    this.ref,
    this.query,
    required this.builder,
  }) : super(key: key);

  final String? path;
  final DocumentReference? ref;
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

    DocumentReference? _ref;
    if (widget.path != null) {
      _ref = FirebaseFirestore.instance.doc(widget.path!);
    } else if (widget.ref != null) {
      _ref = widget.ref!;
    }

    if (_ref != null) {
      sub = _ref.snapshots().listen(
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

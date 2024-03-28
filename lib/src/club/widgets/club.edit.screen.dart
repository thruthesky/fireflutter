import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ClubEditScreen extends StatefulWidget {
  const ClubEditScreen({super.key, this.reference});

  final DocumentReference? reference;

  @override
  State<ClubEditScreen> createState() => _ClubEditScreenState();
}

class _ClubEditScreenState extends State<ClubEditScreen> {
  DocumentReference? ref;

  @override
  void initState() {
    super.initState();

    if (widget.reference != null) {
      ref = widget.reference;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ref == null ? '모임 만들기' : '모임 수정하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ref == null
            ? ClubCreateForm(
                onCreate: (ref) => setState(() => this.ref = ref),
              )
            : ClubUpdateForm(
                reference: ref!,
              ),
      ),
    );
  }
}

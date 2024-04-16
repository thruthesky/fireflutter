import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ClubEditScreen extends StatefulWidget {
  const ClubEditScreen({super.key, this.club});

  final Club? club;

  @override
  State<ClubEditScreen> createState() => _ClubEditScreenState();
}

class _ClubEditScreenState extends State<ClubEditScreen> {
  Club? club;

  @override
  void initState() {
    super.initState();

    if (widget.club != null) {
      club = widget.club;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          club == null ? T.clubCreate.tr : T.clubUpdate.tr,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: club == null
            ? ClubCreateForm(
                onCreate: (club) => setState(() => this.club = club),
              )
            : ClubUpdateForm(
                club: club!,
              ),
      ),
    );
  }
}

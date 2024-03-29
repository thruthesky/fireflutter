import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ClubDoc extends StatelessWidget {
  const ClubDoc({
    super.key,
    required this.club,
    required this.builder,
  });

  final Club club;
  final Widget Function(Club) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Club>(
      initialData: club,
      stream: Club.col.doc(club.id).snapshots().map(
            (event) => Club.fromSnapshot(event),
          ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final club = snapshot.data!;
        print(club);
        return builder(club);
      },
    );
  }
}

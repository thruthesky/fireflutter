import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ClubCard extends StatelessWidget {
  const ClubCard({
    super.key,
    required this.club,
  });

  final Club club;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => ClubService.instance.showViewScreen(
        context: context,
        club: club,
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.teal[100],
        child: Stack(
          children: [
            if (club.photoUrl != null)
              CachedNetworkImage(
                imageUrl: club.photoUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            Text("name is ${club.name}"),
          ],
        ),
      ),
    );
  }
}

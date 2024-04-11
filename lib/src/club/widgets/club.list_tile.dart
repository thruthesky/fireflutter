import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Club list tile
///
/// Club list tile widget to show club information in a list.
class ClubListTile extends StatelessWidget {
  const ClubListTile({
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (club.photoUrl != null)
              CachedNetworkImage(
                imageUrl: club.photoUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 8),
            Text(
              club.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              club.description.cut(128),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('회원 수: ${club.users.length} 명'),
          ],
        ),
      ),
    );
  }
}

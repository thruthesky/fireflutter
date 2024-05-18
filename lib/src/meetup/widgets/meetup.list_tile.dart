import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Meetup list tile
///
/// Meetup list tile widget to show meetup information in a list.
class MeetupListTile extends StatelessWidget {
  const MeetupListTile({
    super.key,
    required this.meetup,
  });

  final Meetup meetup;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => MeetupService.instance.showViewScreen(
        context: context,
        meetup: meetup,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (meetup.photoUrl != null)
              CachedNetworkImage(
                imageUrl: meetup.photoUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 8),
            Text(
              meetup.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              meetup.description.cut(128),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('회원 수: ${meetup.users.length} 명'),
          ],
        ),
      ),
    );
  }
}

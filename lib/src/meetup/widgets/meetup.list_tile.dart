import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Meetup list tile
///
/// Meetup list tile widget to show meetup information in a list.
class MeetupListTile extends StatelessWidget {
  MeetupListTile({
    super.key,
    required this.meetup,
    this.padding = const EdgeInsets.all(16),
    this.contentPadding = const EdgeInsets.all(0),
    this.onTap,
  });

  final Meetup meetup;
  final EdgeInsets padding;
  final EdgeInsets contentPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap != null
          ? onTap!.call()
          : MeetupService.instance.showViewScreen(
              context: context,
              meetup: meetup,
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meetup.photoUrl != null)
            CachedNetworkImage(
              imageUrl: meetup.photoUrl!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) {
                dog('meetup.list_tile: Image url has problem: $error');
                return const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 8,
                ),
                Text(
                  meetup.name,
                  overflow: TextOverflow.clip,
                ),
                const SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    meetup.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.clip,
                    maxLines: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

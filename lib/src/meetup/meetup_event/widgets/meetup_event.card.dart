import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Meetup Event Card
///
/// [meetup] Meetup data model if value exist, check if current user joined the meetup and show date and time
///
/// [event] MeetupEvent data model
///
///
class MeetupEventCard extends StatelessWidget {
  const MeetupEventCard({
    super.key,
    required this.event,
    this.meetup,
  });

  final MeetupEvent event;
  final Meetup? meetup;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => MeetupEventService.instance.showViewScreen(
        context: context,
        event: event,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.photoUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: event.photoUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    dog('meetup_event.card: Image url has problem: $error');
                    return const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                event.title,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (event.description.isNullOrEmpty == false)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (meetup?.joined == true && event.meetAt != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      DateFormat.yMMMEd().format(event.meetAt!),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat.jm().format(event.meetAt!),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

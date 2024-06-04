import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeetupEventCard extends StatelessWidget {
  const MeetupEventCard({
    super.key,
    required this.event,
  });

  final MeetupEvent event;

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
            if (event.meetAt != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      DateFormat.yMMMEd().format(event.meetAt!),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat.jm().format(event.meetAt!),
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

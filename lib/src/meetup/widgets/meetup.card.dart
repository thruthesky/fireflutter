import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/meetup/meetup.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeetupCard extends StatelessWidget {
  const MeetupCard({
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
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: meetup.photoUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              meetup.title,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (meetup.meetAt != null)
              Row(
                children: [
                  Text(DateFormat.yMMMEd('ko').format(meetup.meetAt!)),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat.jm('ko').format(meetup.meetAt!),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

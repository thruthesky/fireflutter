import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/meetup/meetup.service.dart';
import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.all(8),
        color: Colors.teal[100],
        child: Stack(
          children: [
            if (meetup.photoUrl != null)
              CachedNetworkImage(
                imageUrl: meetup.photoUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            Text("Title: ${meetup.title}"),
          ],
        ),
      ),
    );
  }
}

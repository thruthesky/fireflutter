import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Meetup dard
///
/// Meetup card widget to show meetup information in a card.
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
        // padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (meetup.photoUrl != null)
                CachedNetworkImage(
                  imageUrl: meetup.photoUrl!,
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                ),

              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        meetup.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              // Text(
              //   meetup.description.cut(128),
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              // ),
              // Text('회원 수: ${meetup.users.length} 명'),
            ],
          ),
        ),
      ),
    );
  }
}

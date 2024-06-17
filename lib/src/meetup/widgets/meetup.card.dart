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
    this.padding = const EdgeInsets.all(0),
    this.contentPadding = const EdgeInsets.fromLTRB(16, 8, 16, 16),
    this.onTap,
  });

  final Meetup meetup;
  final EdgeInsets padding;
  final EdgeInsets contentPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap != null
            ? onTap!.call()
            : MeetupService.instance.showViewScreen(
                context: context,
                meetup: meetup,
              ),
        child: Container(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (meetup.photoUrl != null)
                CachedNetworkImage(
                  errorWidget: (context, e, _) {
                    return Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    );
                  },
                  errorListener: (error) {
                    dog("meetup card error, please check this CachedNetwork Image: $error");
                  },
                  imageUrl: meetup.photoUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 8),
              Padding(
                padding: contentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Text(
                        '${T.members.tr}: ${meetup.users.length} ${T.noOfPeople.tr}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Club dard
///
/// Club card widget to show club information in a card.
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
        // padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (club.photoUrl != null)
                CachedNetworkImage(
                  imageUrl: club.photoUrl!,
                  width: double.infinity,
                  height: 200,
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
                        club.name,
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
              //   club.description.cut(128),
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              // ),
              // Text('회원 수: ${club.users.length} 명'),
            ],
          ),
        ),
      ),
    );
  }
}

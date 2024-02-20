import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class MyProfileSticker extends StatelessWidget {
  const MyProfileSticker({
    super.key,
    this.spacing = 16.0,
  });

  final double spacing;

  @override
  Widget build(BuildContext context) {
    return MyDoc(
      builder: (my) {
        if (my == null) return const SizedBox.shrink();
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => UserService.instance.showProfile(context),
          child: Row(
            children: [
              SizedBox(width: spacing),
              Avatar(
                photoUrl: my.photoUrl.orAnonymousUrl,
                size: 64,
                radius: 24,
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      my.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      my.stateMessage,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing),
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(
                  '프로필 수정',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ),
              SizedBox(width: spacing),
            ],
          ),
        );
      },
    );
  }
}

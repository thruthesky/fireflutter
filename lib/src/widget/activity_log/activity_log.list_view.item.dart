import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class ActivityLogListTiLeItem extends StatelessWidget {
  const ActivityLogListTiLeItem({
    super.key,
    this.children = const <Widget>[],
    required this.activity,
    required this.actor,
    required this.message,
    this.icon,
  });

  final List<Widget> children;
  final ActivityLog activity;
  final User actor;
  final String message;

  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(
                height: sizeSm,
              ),
              ActivityLogIcons(
                activity: activity,
              ),
              const SizedBox(height: sizeXxs),
              SizedBox(
                width: 64,
                child: Text(
                  dateTimeShort(activity.createdAt),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(width: sizeXs),
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(0),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16),
                child: children.isEmpty
                    ? Row(
                        children: [
                          UserAvatar(
                            user: actor,
                            size: 40,
                            radius: 20,
                            onTap: () {
                              UserService.instance.showPublicProfileScreen(
                                context: context,
                                user: actor,
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              message,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              UserAvatar(
                                user: actor,
                                size: 40,
                                radius: 20,
                                onTap: () {
                                  UserService.instance.showPublicProfileScreen(
                                    context: context,
                                    user: actor,
                                  );
                                },
                              ),
                              const SizedBox(width: sizeXs),
                              Expanded(
                                child: Text(
                                  message,
                                ),
                              ),
                            ],
                          ),
                          ...children,
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

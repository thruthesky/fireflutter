import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendRequestButton extends StatelessWidget {
  const FriendRequestButton({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Value(
      ref: Friend.myReceived(otherUid: uid),
      builder: (myReceivedRequest) {
        if (myReceivedRequest != null) {
          final request = Friend.fromJson(
            Map<String, dynamic>.from(myReceivedRequest),
            Friend.myReceived(otherUid: uid),
          );
          if (request.isAccepted) {
            return const SizedBox.shrink();
          }
          if (request.isRejected) {
            return ElevatedButton(
              onPressed: () async {
                final re = await confirm(
                  context: context,
                  title: T.alreadyRejected.tr,
                  message:
                      T.alreadyRejectedAcceptRequestInsteadConfirmMessage.tr,
                );
                if (re == true) {
                  Friend.accept(context: context, uid: uid);
                }
              },
              child: Text(T.friendRequest.tr),
            );
          }
          return ElevatedButton(
            onPressed: () async {
              final re = await _showRespondRequestDialog(context);
              if (re == true) {
                await Friend.accept(context: context, uid: uid);
              } else if (re == false) {
                await Friend.reject(context: context, uid: uid);
              }
            },
            child: Text(T.respondRequest.tr),
          );
        }
        return Value(
          ref: Friend.mySent(otherUid: uid),
          builder: (mySentRequest) {
            if (mySentRequest == null) {
              return ElevatedButton(
                onPressed: () async {
                  if (uid == myUid) {
                    errorToast(
                      context: context,
                      message: T.youCantAddYourselfAsFriend.tr,
                    );
                    return;
                  }
                  await Friend.request(context: context, uid: uid);
                },
                child: Text(T.friendRequest.tr),
              );
            } else {
              final request = Friend.fromJson(
                Map<String, dynamic>.from(mySentRequest),
                Friend.myReceived(otherUid: uid),
              );
              if (request.isAccepted) {
                return const SizedBox.shrink();
              }
              return ElevatedButton(
                onPressed: () async {
                  final re = await confirm(
                    context: context,
                    title: T.alreadyRequested.tr,
                    message:
                        T.alreadyRequestedCancelRequestInsteadConfirmMessage.tr,
                  );
                  if (re == true) {
                    await Friend.cancel(context: context, uid: uid);
                  }
                },
                child: Text(T.requested.tr),
              );
            }
          },
        );
      },
    );
  }

  /// Shows Accept, Reject, or Cancel dialog.
  ///
  /// Accept = true
  /// Reject = false
  /// Cancel = null
  Future<bool?> _showRespondRequestDialog(BuildContext context) {
    return showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.only(top: 16.0),
          title: Text(T.respondRequest.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Text(T.thisUserWantsToAddYouAsFriend.tr),
              ),
              const Divider(
                height: 0,
              ),
              InkWell(
                onTap: () => Navigator.pop(context, true),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      T.accept.tr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green,
                          ),
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 0,
              ),
              InkWell(
                onTap: () => Navigator.pop(context, false),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      T.reject.tr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 0,
              ),
              InkWell(
                onTap: () => Navigator.pop(context, null),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      T.cancel.tr,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

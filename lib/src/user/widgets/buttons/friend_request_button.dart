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
                  title: "Already Rejected",
                  message:
                      "You have already rejected this user. Do you want to accept the request instead?",
                );
                if (re == true) {
                  Friend.acceptRequest(context: context, uid: uid);
                }
              },
              child: const Text("Friend Request"),
            );
          }
          return ElevatedButton(
            onPressed: () async {
              final re = await _showRespondRequestDialog(context);
              if (re == true) {
                await Friend.acceptRequest(context: context, uid: uid);
              } else if (re == false) {
                await Friend.rejectRequest(context: context, uid: uid);
              }
            },
            child: const Text('Respond Request'),
          );
        }
        return Value(
          ref: Friend.mySent(otherUid: uid),
          builder: (mySentRequest) {
            if (mySentRequest == null) {
              return ElevatedButton(
                onPressed: () async {
                  if (uid == myUid) {
                    toast(
                      context: context,
                      message: "You can't add yourself as friend.",
                    );
                    return;
                  }
                  await Friend.request(context: context, uid: uid);
                },
                child: const Text('Friend Request'),
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
                    title: "Already Requested",
                    message:
                        "You have already requested this user. Do you want to cancel the request?",
                  );
                  if (re == true) {
                    await Friend.cancelRequest(context: context, uid: uid);
                  }
                },
                child: const Text('Requested'),
              );
            }
          },
        );
      },
    );
  }

  /// Shows Accept, Reject, or Cancel
  /// Accept = true
  /// Reject = false
  /// Cancel = null
  Future<bool?> _showRespondRequestDialog(BuildContext context) {
    return showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.only(top: 16.0),
          title: const Text("Respond Request"),
          // content: const Text("Do you want to accept, reject the request?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              InkWell(
                onTap: () => Navigator.pop(context, true),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "Accept",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green,
                          ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context, false),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "Reject",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context, null),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text("Cancel")),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

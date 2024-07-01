import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendRequestButton extends StatefulWidget {
  const FriendRequestButton({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  State<FriendRequestButton> createState() => _FriendRequestButtonState();
}

class _FriendRequestButtonState extends State<FriendRequestButton> {
  Friend? myReceivedRequest;
  Friend? mySentRequest;

  bool get _isAccepted => [myReceivedRequest?.status, mySentRequest?.status]
      .contains(FriendStatus.accepted);
  bool get _isRejectedByMe =>
      myReceivedRequest?.status == FriendStatus.rejected;
  bool get _isWaitingForMyResponse =>
      myReceivedRequest?.status == FriendStatus.pending;
  bool get _isPendingOrRejectedByOther =>
      mySentRequest?.status == FriendStatus.pending ||
      mySentRequest?.status == FriendStatus.rejected;

  String get _buttonText {
    if (_isAccepted) return T.friends.tr;
    if (_isRejectedByMe) return T.friendRequest.tr;
    if (_isWaitingForMyResponse) return T.respondRequest.tr;
    if (_isPendingOrRejectedByOther) return T.requested.tr;
    return T.friendRequest.tr;
  }

  @override
  Widget build(BuildContext context) {
    return Value(
      ref: Friend.myReceived(otherUid: widget.uid),
      builder: (myReceivedRequestData) => Value(
        ref: Friend.mySent(otherUid: widget.uid),
        builder: (mySentRequestData) {
          myReceivedRequest = myReceivedRequestData != null
              ? Friend.fromJson(
                  Map<String, dynamic>.from(myReceivedRequestData),
                  Friend.myReceived(otherUid: widget.uid),
                )
              : null;
          mySentRequestData = mySentRequestData != null
              ? Friend.fromJson(
                  Map<String, dynamic>.from(mySentRequestData),
                  Friend.mySent(otherUid: widget.uid),
                )
              : null;
          return ElevatedButton(
            onPressed: () async {
              // If you are already friends
              if (_isAccepted) {
                toast(
                  context: context,
                  message: "You are friends already.",
                );
              }
              // If you rejected the received request
              else if (_isRejectedByMe) {
                final re = await confirm(
                  context: context,
                  title: T.alreadyRejected.tr,
                  message:
                      T.alreadyRejectedAcceptRequestInsteadConfirmMessage.tr,
                );
                if (re == true) {
                  Friend.accept(context: context, uid: widget.uid);
                }
              }
              // If the other person has sent you a request, and the status is still pending.
              else if (_isWaitingForMyResponse) {
                final re = await _showRespondRequestDialog(context);
                if (re == true) {
                  await Friend.accept(context: context, uid: widget.uid);
                } else if (re == false) {
                  await Friend.reject(context: context, uid: widget.uid);
                }
              }
              // If there is a pending friend request or the other person has rejected the request
              // We are not showing if the user is rejected.
              else if (_isPendingOrRejectedByOther) {
                final re = await confirm(
                  context: context,
                  title: T.alreadyRequested.tr,
                  message:
                      T.alreadyRequestedCancelRequestInsteadConfirmMessage.tr,
                );
                if (re == true) {
                  await Friend.cancel(context: context, uid: widget.uid);
                }
              }
              // Else means there is no friend request yet
              else {
                if (widget.uid == myUid) {
                  errorToast(
                    context: context,
                    message: T.youCantAddYourselfAsFriend.tr,
                  );
                  return;
                }
                await Friend.request(context: context, uid: widget.uid);
              }
            },
            child: Text.rich(
              TextSpan(
                children: [
                  if (_isAccepted) ...[
                    const WidgetSpan(
                      child: Icon(
                        Icons.check,
                        size: 16,
                      ),
                    ),
                    const TextSpan(text: "  "),
                  ],
                  TextSpan(text: _buttonText),
                ],
              ),
            ),
          );
        },
      ),
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/chat/widgets/chat.read_more.dialog.dart';
import 'package:flutter/material.dart';

/// Chat bubble
///
/// Displays a chat message.
///
/// If [uid] is blocked, show a message that the user is blocked.
///
/// If the chat bubble needs to be rebuild when something chagned, [onChange]
/// will be called. One example is when the login user open's other's profile
/// and block/unblock.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.room,
    required this.message,
    this.onChange,
    this.onReply,
    this.onEdit,
  });

  final ChatRoom room;
  final ChatMessage message;
  final Function? onChange;
  final void Function(ChatMessage message)? onReply;
  final void Function(ChatMessage message)? onEdit;

  bool get isLongText =>
      message.text != null &&
      (message.text!.length > 360 ||
          '\n'.allMatches(message.text!).length > 10);

  String get text {
    if (message.text == null) return '';
    if (isLongText) {
      String t = message.text!;
      final splits = t.split('\n');
      if (splits.length > 10) {
        return '${splits.sublist(0, 10).join('\n')}...';
      } else {
        return '${message.text!.substring(0, 360)}...';
      }
    } else {
      return message.text!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.mine) ...[
            const Spacer(),
            dateAndName(context: context, uid: myUid!),
          ],

          /// Other user avtar. size 30.
          if (message.other)
            UserAvatar(
              key: ValueKey(message.key),
              uid: message.uid!,
              cacheId: message.uid,
              size: 30,
              radius: 12,
              onTap: () => mayShowPublicProfileScreen(context, message.uid!),
            ),

          const SizedBox(width: 8),
          // Chat message text. size 60%

          if (message.deleted ||
              (message.text != null && message.text!.isNotEmpty))
            ChatBubblePopupMenuButton(
              message: message,
              room: room,
              onViewProfile: () =>
                  mayShowPublicProfileScreen(context, message.uid!),
              onDeleteMessage: () async {
                // Added Future.delayed by @withcenter-dev2 at 2024-05-30
                // because showing a dialog is having a problem here.
                // What I think is happening:
                // in DropdownButton2, when onChange is called, it pops the dropdown.
                // So when we showDialog, suddenly it pops it. Then it returns 'bool?' but
                // it was expecting '_DropdownButton2<String>' (because it wanted to pop the dropdown)
                // For confirmation. Because we may need a better solution.
                await Future.delayed(const Duration(milliseconds: 1));
                final deleteConfirmation = await confirm(
                  context: context,
                  title: "Delete Message",
                  message:
                      "Are you sure you want to delete this message? This action cannot be undone.",
                );
                if (deleteConfirmation ?? false) {
                  await message.delete();
                }
              },
              onBlock: () => room.block(message.uid!),
              onReply: () => print("onReply?.call(message);"),
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: message.mine
                            ? Colors.amber.shade200
                            : Colors.grey.shade200,
                        borderRadius: borderRadius(),
                      ),
                      child: message.deleted
                          ? Text(T.chatMessageDeleted.tr)
                          : LinkifyText(
                              selectable: false,
                              text.orBlocked(
                                  message.uid!, T.blockedChatMessage),
                              style: const TextStyle(color: Colors.black),
                            ),
                    ),
                    if (isLongText)
                      TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ChatReadMoreDialog(
                                message: message,
                              ),
                            );
                          },
                          child: Text(T.readMore.tr)),
                    if (message.hasUrlPreview) ...[
                      const SizedBox(height: 8),
                      UrlPreview(
                        previewUrl: message.previewUrl!,
                        title: message.previewTitle,
                        description: message.previewDescription,
                        imageUrl: message.previewImageUrl,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          // image
          if (message.url != null) cachedImage(context, message.url!),

          const SizedBox(width: 8),

          /// Login user's avatar (my avtar)
          ///
          if (message.mine)
            UserAvatar(
              uid: myUid!,
              initialData: my?.photoUrl,
              sync: true,
              size: 30,
              radius: 12,
              onTap: () => mayShowPublicProfileScreen(context, myUid!),
            ),

          if (!message.mine) ...[
            dateAndName(context: context, uid: message.uid!),
            const Spacer(),
          ],
        ],
      ),
    );
  }

  mayShowPublicProfileScreen(BuildContext context, String uid) {
    UserService.instance
        .showPublicProfileScreen(
          context: context,
          uid: message.uid!,
        )
        .then(
          // * when the profile is updated, the chat bubble does not reflect the change of profile
          // * But for blocking/unblocking will be updated by this callback.
          (value) => onChange?.call(),
        );
  }

  borderRadius() {
    return BorderRadius.only(
      topLeft: Radius.circular(message.mine ? 16 : 0),
      topRight: Radius.circular(message.mine ? 0 : 16),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
    );
  }

  /// Display date and name
  ///
  /// The width of the name is 20% of the screen width to prevent the overflow.
  dateAndName({
    required BuildContext context,
    required String uid,
  }) {
    return Column(
      crossAxisAlignment:
          message.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        DateTimeShort(stamp: message.createdAt ?? 0),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.2,
          ),
          child: UserDisplayName(
            uid: uid,
            cacheId: 'chatRoom',
            style: Theme.of(context).textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  cachedImage(BuildContext context, String url) {
    if (iHave.blocked(message.uid!)) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: borderRadius(),
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        child: CachedNetworkImage(
          imageUrl: message.url!,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
          // if thumbnail is not available, show original image
          errorWidget: (context, url, error) {
            return const Icon(Icons.error_outline, color: Colors.red);
          },
          errorListener: (value) => dog('Image not exist in storage: $value'),
        ),
      ),
    );
  }
}

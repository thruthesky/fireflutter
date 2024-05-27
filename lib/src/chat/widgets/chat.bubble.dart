import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
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
  });

  final ChatRoom room;
  final ChatMessage message;
  final Function? onChange;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
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

          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: message.mine
                        ? Colors.amber.shade200
                        : Colors.grey.shade200,
                    borderRadius: borderRadius(),
                  ),
                  child: message.text != null && message.deleted == false
                      ? LinkifyText(
                          message.text!
                              .orBlocked(message.uid!, T.blockedChatMessage),
                          style: const TextStyle(color: Colors.black),
                        )
                      : Text(T.chatMessageDeleted.tr),
                ),
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

    /// 관리자가 아니고, 방장이 아니면, 그냥 chat bubble 만 리턴
    if (isAdmin == false && room.isMaster == false) {
      return bubble;
    }

    /// 관리자이거나 방장이면, 팝업 메뉴 버튼을 리턴
    return PopupMenuButton(
      position: PopupMenuPosition.under,
      onOpened: () => FocusScope.of(context).unfocus(),
      offset: Offset(
        message.mine ? MediaQuery.of(context).size.width : 0,
        0,
      ),
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: Code.delete,
          child: Text(T.chatMessageDelete.tr),
        ),
        PopupMenuItem(
          value: Code.block,
          child: Text(T.block.tr),
        ),
      ],
      onSelected: (v) async {
        switch (v) {
          case Code.delete:
            await message.delete();
            break;
          case Code.block:

            /// 여기서 부터..
            await room.block(message.uid!);
            break;
          default:
            break;
        }
      },
      child: IgnorePointer(child: bubble),
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

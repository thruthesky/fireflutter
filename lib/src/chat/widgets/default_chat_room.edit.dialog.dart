import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Chat room create or update
///
///
///
class DefaultChatRoomEditDialog extends StatefulWidget {
  const DefaultChatRoomEditDialog({
    super.key,
    this.roomId,
    this.authRequired = false,
  });

  final String? roomId;
  final bool authRequired;

  @override
  State<DefaultChatRoomEditDialog> createState() =>
      _DefaultChatRoomEditDialogState();
}

class _DefaultChatRoomEditDialogState extends State<DefaultChatRoomEditDialog> {
  bool open = false;
  bool isVerifiedOnly = false;
  bool urlVerifiedUserOnly = false;
  bool uploadVerifiedUserOnly = false;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final passwordController = TextEditingController();

  bool get isEdit => widget.roomId != null;
  bool get isCreate => widget.roomId == null;
  ChatRoom? room;

  double? progress;
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (isEdit) {
      /// 채팅방 수정의 경우, 기존 채팅방 정보를 가져와 초기화 한다.
      room = await ChatRoom.get(widget.roomId!);
      nameController.text = room?.name ?? '';
      descriptionController.text = room?.description ?? '';
      // TODO cleanup
      // Commented by @withcenter-dev2 2024-05-30
      // open = room?.isGroupChat ?? false;
      open = (room?.isGroupChat ?? false) ? (room!.isOpenGroupChat) : false;
      isVerifiedOnly = room?.isVerifiedOnly ?? false;
      urlVerifiedUserOnly = room?.urlVerifiedUserOnly ?? false;
      uploadVerifiedUserOnly = room?.uploadVerifiedUserOnly ?? false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEdit && room?.isMaster == false && isAdmin == false) {
      return const ErrorDialog(
        title: '권한 없음',
        message: '채팅방을 수정할 권한이 없습니다.',
      );
    }

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Text(
              isCreate ? '새로운 채팅' : '채팅방 설정',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  // TODO trs
                  labelText: '채팅방 이름',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  // TODO trs
                  labelText: '채팅방 설명',
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Password
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  // TODO trs
                  labelText: '가입 비밀번호',
                  hintText: '비워두면 비밀번호가 필요하지 않습니다.',
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (isEdit)
              Value(
                // path: "${ChatRoom.node}/${widget.roomId}/${Field.iconUrl}",
                ref: ChatRoom.iconUrlRef(widget.roomId!),
                builder: (url) {
                  return url == null
                      ? const SizedBox()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        );
                },
              ),

            // 채팅방 아이콘 업로드는 - 채팅방이 먼저 존재해야, 아이콘 URL 을 쉽게 저장 할 수 있다.
            if (isEdit)
              progress == null || progress?.isNaN == true
                  ? TextButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('채팅방 아이콘 업로드'),
                      onPressed: () async {
                        await StorageService.instance.uploadAt(
                          context: context,
                          path:
                              "${ChatRoom.node}/${widget.roomId}/${Field.iconUrl}",
                          progress: (p) => setState(() => progress = p),
                          complete: () => setState(() => progress = null),
                        );
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(value: progress),
                    ),
            SwitchListTile(
              value: open,
              onChanged: (v) => setState(() => open = v),
              title: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '오픈 채팅',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '다른 사용자가 채팅방에 참여할 수 있습니다.',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            if (widget.authRequired)
              SwitchListTile(
                value: isVerifiedOnly,
                onChanged: (v) => setState(() => isVerifiedOnly = v),
                title: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '인증 회원 전용 입장',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '본인 인증 한 회원만 채팅방에 참여할 수 있습니다.',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
            if (isEdit)
              SwitchListTile(
                value: urlVerifiedUserOnly,
                onChanged: (v) => setState(() => urlVerifiedUserOnly = v),
                title: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '인증 회원 전용 URL 입력',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '본인 인증 한 회원만 URL 링크를 입력 할 수 있습니다.',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
            if (isEdit)
              SwitchListTile(
                value: uploadVerifiedUserOnly,
                onChanged: (v) => setState(() => uploadVerifiedUserOnly = v),
                title: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '인증 회원 전용 사진 등록',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    '본인 인증 한 회원만 사진을 등록 할 수 있습니다.',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.isEmpty ||
                descriptionController.text.isEmpty) {
              error(
                context: context,
                title: '',
                message: '채팅방 이름과 설명을 입력해주세요',
              );
              return;
            }
            if (isCreate) {
              final room = await ChatRoom.create(
                name: nameController.text,
                description: descriptionController.text,
                isOpenGroupChat: open,
              );

              /// 채팅방을 생성하는 경우, chat-joins 에도 정보를 저장한다.
              ///
              final chat = ChatModel(room: room);
              await chat.room.join(forceJoin: true);

              if (context.mounted) {
                Navigator.pop(context, room);
              }
            } else {
              await room?.update(
                name: nameController.text,
                description: descriptionController.text,
                isOpenGroupChat: open,
                isVerifiedOnly: isVerifiedOnly,
                urlVerifiedUserOnly: urlVerifiedUserOnly,
                uploadVerifiedUserOnly: uploadVerifiedUserOnly,
              );
              if (context.mounted) {
                Navigator.pop(context, room);
              }
            }
          },
          child: Text(isCreate ? '생성' : '수정'),
        ),
      ],
    );
  }
}

import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DefaultChatRoomEditDialog extends StatefulWidget {
  const DefaultChatRoomEditDialog({
    super.key,
    this.roomId,
  });

  final String? roomId;

  @override
  State<DefaultChatRoomEditDialog> createState() => _DefaultChatRoomEditDialogState();
}

class _DefaultChatRoomEditDialogState extends State<DefaultChatRoomEditDialog> {
  bool open = false;
  bool verified = false;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  bool get isEdit => widget.roomId != null;
  bool get isCreate => widget.roomId == null;
  ChatRoomModel? room;
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (isEdit) {
      /// 채팅방 수정의 경우, 기존 채팅방 정보를 가져와 초기화 한다.
      room = await ChatRoomModel.get(widget.roomId!);
      nameController.text = room?.name ?? '';
      descriptionController.text = room?.description ?? '';
      open = room?.isGroupChat ?? false;
      verified = room?.verified ?? false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Text(isCreate ? '새로운 채팅' : '채팅방 설정', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
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
                labelText: '채팅방 설명',
              ),
            ),
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
          SwitchListTile(
            value: verified,
            onChanged: (v) => setState(() => verified = v),
            title: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '인증 회원 전용',
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
              error(
                context: context,
                title: '',
                message: '채팅방 이름과 설명을 입력해주세요',
              );
              return;
            }
            if (isCreate) {
              final room = await ChatRoomModel.create(
                name: nameController.text,
                description: descriptionController.text,
                isOpenGroupChat: open,
              );

              if (context.mounted) {
                Navigator.pop(context, room);
              }
            } else {
              await room?.update(
                name: nameController.text,
                description: descriptionController.text,
                isOpenGroupChat: open,
                verified: verified,
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: Text(isCreate ? '생성' : '수정'),
        ),
      ],
    );
  }
}

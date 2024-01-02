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
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Text('채로운 채팅', style: Theme.of(context).textTheme.titleLarge),
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
          const SizedBox(height: 8),
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

            final room = await ChatRoomModel.create(
              name: nameController.text,
              description: descriptionController.text,
              isOpenGroupChat: open,
            );

            if (context.mounted) {
              Navigator.pop(context, room);
            }
          },
          child: const Text('전송'),
        ),
      ],
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
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
    this.showAuthRequiredOption = false,
  });

  final String? roomId;
  final bool showAuthRequiredOption;

  @override
  State<DefaultChatRoomEditDialog> createState() =>
      _DefaultChatRoomEditDialogState();
}

class _DefaultChatRoomEditDialogState extends State<DefaultChatRoomEditDialog> {
  bool open = true;
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

  String? genderGroupValue = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> init() async {
    if (isEdit) {
      /// 채팅방 수정의 경우, 기존 채팅방 정보를 가져와 초기화 한다.
      room = await ChatRoom.get(widget.roomId!);
      nameController.text = room?.name ?? '';
      descriptionController.text = room?.description ?? '';
      open = (room?.isGroupChat ?? false) ? (room!.isOpenGroupChat) : false;
      isVerifiedOnly = room?.isVerifiedOnly ?? false;
      urlVerifiedUserOnly = room?.urlVerifiedUserOnly ?? false;
      uploadVerifiedUserOnly = room?.uploadVerifiedUserOnly ?? false;
      genderGroupValue = room?.gender ?? '';

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEdit && room?.isMaster == false && isAdmin == false) {
      return ErrorDialog(
        title: T.noPermission.tr,
        message: T.noPermissionModifyChatRoom.tr,
      );
    }

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Text(
                isCreate ? T.newChat.tr : T.chatRoomSettings.tr,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: T.chatRoomName.tr,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: T.chatRoomDescription.tr,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isEdit)
              Value(
                ref: ChatRoom.iconUrlRef(widget.roomId!),
                builder: (url) {
                  return url == null
                      ? const SizedBox()
                      : Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) {
                                return const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                );
                              },
                              errorListener: (value) => dog(
                                  'default_chat_room.edit.dialog.dart: Image has problem: $value'),
                            ),
                          ),
                        );
                },
              ),

            // 채팅방 아이콘 업로드는 - 채팅방이 먼저 존재해야, 아이콘 URL 을 쉽게 저장 할 수 있다.
            if (isEdit)
              progress == null || progress?.isNaN == true
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: TextButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: Text(T.uploadChatRoomIcon.tr),
                        onPressed: () async {
                          await StorageService.instance.uploadAt(
                            context: context,
                            path:
                                "${ChatRoom.node}/${widget.roomId}/${Field.iconUrl}",
                            progress: (p) => setState(() => progress = p),
                            complete: () => setState(() => progress = null),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(value: progress),
                      ),
                    ),
            SwitchListTile(
              value: open,
              onChanged: (v) => setState(() => open = v),
              title: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  T.openChat.tr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  T.anyoneCanJoinChat.tr,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),

            /// TODO change the term 'auth' to 'verified'.
            if (widget.showAuthRequiredOption)
              SwitchListTile(
                value: isVerifiedOnly,
                onChanged: (v) => setState(() => isVerifiedOnly = v),
                title: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    T.verifiedMembersOnly.tr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    T.onlyVerifiedMembersCanJoinChat.tr,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            if (isEdit) ...[
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Text(
                  T.gender.tr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8),
                child: Row(
                  children: [
                    RadioMenuButton(
                      value: '',
                      groupValue: genderGroupValue,
                      onChanged: (v) => setState(() => genderGroupValue = v),
                      child: Text(T.all.tr),
                    ),
                    RadioMenuButton(
                      value: 'M',
                      groupValue: genderGroupValue,
                      onChanged: (v) => setState(() => genderGroupValue = v),
                      child: Text(T.male.tr),
                    ),
                    RadioMenuButton(
                      value: 'F',
                      groupValue: genderGroupValue,
                      onChanged: (v) => setState(() => genderGroupValue = v),
                      child: Text(T.female.tr),
                    ),
                  ],
                ),
              ),
            ],

            /// Password
            if (isEdit && room != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FutureBuilder<DataSnapshot>(
                    future: ChatService.instance.settingRef(room!.id).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      if (snapshot.hasError) {
                        debugPrint('Error: ${snapshot.error}');
                        return Text(snapshot.error.toString());
                      }
                      if (snapshot.hasData == false) {
                        return const SizedBox.shrink();
                      }
                      final data = snapshot.data?.value as Map?;
                      if (data != null && data[Field.password] != null) {
                        passwordController.text =
                            data[Field.password] as String;
                      }
                      return TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: T.passwordToJoin.tr,
                          hintText: T.leaveEmptyPasswordIfNotRequired.tr,
                        ),
                      );
                    }),
              ),
            const SizedBox(height: 16),

            if (isEdit)
              SwitchListTile(
                value: urlVerifiedUserOnly,
                onChanged: (v) => setState(() => urlVerifiedUserOnly = v),
                title: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    T.onlyVerifiedMembersCanSendUrl.tr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    T.membersNeedToBeVerifiedToSendMessage.tr,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
            if (isEdit)
              ListTileTheme(
                child: SwitchListTile(
                  value: uploadVerifiedUserOnly,
                  onChanged: (v) => setState(() => uploadVerifiedUserOnly = v),
                  title: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      T.photoUploadOnlyForVerified.tr,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      T.membersNeedToBeVerifiedToUploadPhoto.tr,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(T.cancel.tr),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.isEmpty ||
                descriptionController.text.isEmpty) {
              error(
                context: context,
                title: '',
                message: T.pleaseEnterChatRoomNameAndDescription.tr,
              );
              return;
            }
            if (isCreate) {
              final room = await ChatRoom.create(
                name: nameController.text,
                description: descriptionController.text,
                isOpenGroupChat: open,
                isVerifiedOnly: isVerifiedOnly,
              );

              /// 채팅방을 생성하는 경우, chat-joins 에도 정보를 저장한다.
              ///
              final chat = ChatModel(room: room);
              await chat.room.join(forceJoin: true);

              if (context.mounted) {
                Navigator.pop(context, room);
              }
            } else {
              // Set password
              await ChatService.instance.setRoomPassword(
                roomId: room!.id,
                password: passwordController.text.isEmpty
                    ? null
                    : passwordController.text,
              );

              await room?.update(
                name: nameController.text,
                description: descriptionController.text,
                isOpenGroupChat: open,
                isVerifiedOnly: isVerifiedOnly,
                gender: genderGroupValue,
                urlVerifiedUserOnly: urlVerifiedUserOnly,
                uploadVerifiedUserOnly: uploadVerifiedUserOnly,
                hasPassword: passwordController.text.isNotEmpty,
              );

              if (context.mounted) {
                Navigator.pop(context, room);
              }
            }
          },
          child: Text(isCreate ? T.create.tr : T.save.tr),
        ),
      ],
    );
  }
}

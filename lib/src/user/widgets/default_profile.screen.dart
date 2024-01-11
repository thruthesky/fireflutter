import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DefaultProfileScreen extends StatefulWidget {
  const DefaultProfileScreen({super.key});

  @override
  State<DefaultProfileScreen> createState() => _DefaultProfileScreenState();
}

class _DefaultProfileScreenState extends State<DefaultProfileScreen> {
  double? progress;
  final nameController = TextEditingController();
  final stateMessageController = TextEditingController();

  UserModel get user => UserService.instance.user!;

  @override
  void initState() {
    super.initState();
    nameController.text = user.displayName ?? '';
    stateMessageController.text = user.stateMessage ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Code.profileUpdate.tr),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        MyDoc(builder: (my) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 60),
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  my?.profileBackgroundImageUrl ?? blackUrl,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black54,
                                  Colors.transparent,
                                ]),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: progress != null
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${(progress! * 100).toStringAsFixed(0)} %',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(color: Colors.white),
                                  ),
                                )
                              : TextButton.icon(
                                  onPressed: () async {
                                    await StorageService.instance.uploadAt(
                                      context: context,
                                      path:
                                          "${Folder.users}/${user.uid}/${Field.profileBackgroundImageUrl}",
                                      progress: (p) => setState(() => progress = p),
                                      complete: () => setState(() => progress = null),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    '배경 사진',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: DefaultAvatarUpdate(
                              uid: myUid!,
                              radius: 80,
                              delete: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text("프로필 사진"),
                    const SizedBox(height: 8),
                    Text(
                      "본인 얼굴을 정면으로 가깝게 찍어주세요.",
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '이름',
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  "본인 인증에 사용됩니다. 반드시 본명을 입력하세요.",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: stateMessageController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '상태메시지',
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  "프로필 보기에 나오는 나의 상태메시지입니다.",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('이름을 입력하세요.'),
                        ),
                      );
                      return;
                    }

                    await UserService.instance.user?.update(
                      name: nameController.text,
                      displayName: nameController.text,
                      stateMessage: stateMessageController.text,
                    );

                    if (mounted) toast(context: context, message: '저장되었습니다.');
                  },
                  child: const Text(
                    '저장',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DefaultProfileUpdateForm extends StatefulWidget {
  const DefaultProfileUpdateForm({
    super.key,
    this.occupation = false,
    this.stateMessage = true,
  });

  final bool occupation;
  final bool stateMessage;
  @override
  State<DefaultProfileUpdateForm> createState() =>
      _DefaultProfileUpdateFormState();
}

class _DefaultProfileUpdateFormState extends State<DefaultProfileUpdateForm> {
  double? progress;
  final nameController = TextEditingController();
  final occupationController = TextEditingController();
  final stateMessageController = TextEditingController();

  UserModel get user => UserService.instance.user!;

  @override
  void initState() {
    super.initState();
    nameController.text = user.displayName;
    stateMessageController.text = user.stateMessage;
    occupationController.text = user.occupation;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                            my!.profileBackgroundImageUrl.orBlackUrl,
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
                            label: Text(
                              T.backgroundImage.tr,
                              style: const TextStyle(color: Colors.white),
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
              Text(T.profilePhoto.tr),
              const SizedBox(height: 8),
              Text(
                T.takePhotoClosely.tr,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 64),

        /// Name
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: T.name.tr,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            T.nameInputDescription.tr,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),

        /// Occupatoin
        if (widget.occupation) ...[
          const SizedBox(height: 32),
          TextField(
            controller: occupationController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: T.occupation.tr,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              T.occupationInputDescription.tr,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
        if (widget.stateMessage) ...[
          /// State Message
          const SizedBox(height: 32),

          TextField(
            controller: stateMessageController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: T.stateMessage.tr,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              T.stateMessageDescription.tr,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
        const SizedBox(height: 32),
        MyDoc(builder: (my) => UpdateBirthdayField(user: user)),
        const SizedBox(height: 32),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(T.inputName.tr),
                  ),
                );
                return;
              }

              await my?.update(
                name: nameController.text,
                displayName: nameController.text,
                stateMessage: stateMessageController.text,
                occupation: occupationController.text,
              );

              if (mounted) toast(context: context, message: T.saved.tr);
            },
            child: Text(
              T.save.tr,
            ),
          ),
        ),
      ],
    );
  }
}

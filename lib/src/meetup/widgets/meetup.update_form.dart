import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MeetupUpdateForm extends StatefulWidget {
  const MeetupUpdateForm({
    super.key,
    required this.meetup,
  });

  final Meetup meetup;

  @override
  State<MeetupUpdateForm> createState() => _MeetupUpdateFormState();
}

class _MeetupUpdateFormState extends State<MeetupUpdateForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isVerifiedOnly = false;

  get meetup => widget.meetup;

  @override
  void initState() {
    super.initState();

    nameController.text = meetup.name;
    descriptionController.text = meetup.description ?? '';
    isVerifiedOnly = meetup.isVerifiedOnly;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              StorageService.instance.delete(meetup.photoUrl);
              final url = await StorageService.instance.upload(
                context: context,
                progress: (p0) => print(p0),
                complete: () => print('complete'),
              );
              if (url == null) return;

              await meetup.update(photoUrl: url);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: MeetupDoc(
                meetup: meetup,
                builder: (Meetup meetup) => Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: meetup.photoUrl.isNullOrEmpty
                      ? Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 100,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: meetup.photoUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) {
                            dog('meetup.update_form: Image url has problem: $error');
                            return const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              T.meetupPhotoDescription.tr,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: 24),
          LabelField(
            controller: nameController,
            label: T.meetupName.tr,
            description: T.meetupNameDescription.tr,
          ),
          LabelField(
            controller: descriptionController,
            label: T.meetupDescriptionLabel.tr,
            description: T.meetupDescriptionInputDescription.tr,
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            value: isVerifiedOnly,
            onChanged: (v) => setState(() => isVerifiedOnly = v),
            title: Text(
              T.verifiedMembersOnly.tr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            subtitle: Text(
              T.onlyVerifiedMembersCanJoinChat.tr,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: 24),
          Align(
            child: OutlinedButton(
              onPressed: () async {
                await meetup.update(
                  name: nameController.text,
                  description: descriptionController.text,
                  isVerifiedOnly: isVerifiedOnly,
                );
                toast(context: context, message: T.meetupUpdateMessage.tr);
              },
              child: Text(T.meetupUpdate.tr),
            ),
          ),
        ],
      ),
    );
  }
}

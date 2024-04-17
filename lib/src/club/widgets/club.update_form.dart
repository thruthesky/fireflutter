import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ClubUpdateForm extends StatefulWidget {
  const ClubUpdateForm({
    super.key,
    required this.club,
  });

  final Club club;

  @override
  State<ClubUpdateForm> createState() => _ClubUpdateFormState();
}

class _ClubUpdateFormState extends State<ClubUpdateForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  get club => widget.club;

  @override
  void initState() {
    super.initState();

    nameController.text = club.name;
    descriptionController.text = club.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text('Club ID: ${club.id}'),
          // Text('owner uid: ${club.uid}'),
          // Text('my Uid: ${UserService.instance.user!.uid}'),
          GestureDetector(
            onTap: () async {
              StorageService.instance.delete(club.photoUrl);
              final url = await StorageService.instance.upload(
                context: context,
                progress: (p0) => print(p0),
                complete: () => print('complete'),
              );
              if (url == null) return;

              await club.update(photoUrl: url);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: ClubDoc(
                club: club,
                builder: (Club club) => Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: club.photoUrl.isNullOrEmpty
                      ? Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 100,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: club.photoUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            T.clubPhotoDescription,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 24),
          LabelField(
            controller: nameController,
            label: T.clubName.tr,
            description: T.clubNameDescription.tr,
          ),
          LabelField(
            controller: descriptionController,
            label: T.clubDescriptionLabel.tr,
            description: T.clubDescriptionInputDescription.tr,
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          Align(
            child: OutlinedButton(
              onPressed: () async {
                await club.update(
                  name: nameController.text,
                  description: descriptionController.text,
                );
                toast(context: context, message: T.clubUpdateMessage.tr);
              },
              child: Text(T.clubUpdate.tr),
            ),
          ),
        ],
      ),
    );
  }
}

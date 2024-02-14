import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DefaultProfileUpdateForm extends StatefulWidget {
  const DefaultProfileUpdateForm({
    super.key,
    this.occupation = false,
    this.stateMessage = true,
    this.gender = true,
    this.nationality = false,
    this.region = true,
    this.nationalityTheme,
    this.onUpdate,
    this.countryFilter,
    this.dialogSize,
  });

  final void Function()? onUpdate;
  // use [occupation] to hide the occupation field
  final bool occupation;
  final bool stateMessage;
  final bool gender;
  final bool nationality;
  final bool region;
  final BoxDecoration? nationalityTheme;
  // use countryFilter to list only the country you want to display in the screen
  final List<String>? countryFilter;
  final Size? dialogSize;

  @override
  State<DefaultProfileUpdateForm> createState() =>
      DefaultProfileUpdateFormState();
}

class DefaultProfileUpdateFormState extends State<DefaultProfileUpdateForm> {
  double? progress;
  final nameController = TextEditingController();
  String? nationality;
  String? region;
  final occupationController = TextEditingController();
  final stateMessageController = TextEditingController();
  String? gender;

  UserModel get user => UserService.instance.user!;

  @override
  void initState() {
    super.initState();

    nameController.text = my?.displayName ?? '';
    if (user.nationality != '') {
      nationality = user.nationality;
    }
    if (user.region != '') {
      region = user.region;
    }
    if (user.gender != '') {
      gender = user.gender;
    }

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
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: UserAvatarUpdate(
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
        const SizedBox(height: 32),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: T.name.tr,
          ),
        ),
        if (widget.stateMessage) ...{
          const SizedBox(height: 32),
          TextField(
            controller: stateMessageController,
            decoration: InputDecoration(
              labelText: T.stateMessage.tr,
            ),
          ),
        },
        if (widget.gender) ...{
          const SizedBox(height: 32),
          const Text('Gender'),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withAlpha(128),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.only(
              right: 8,
              top: 4,
              left: 8,
              bottom: 4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Male'),
                    value: 'Male',
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Female'),
                    value: 'Female',
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        },
        if (widget.nationality) ...{
          const SizedBox(
            height: 32,
          ),
          const Text('Nationality'),
          Container(
            width: double.infinity,
            decoration: widget.nationalityTheme,
            child: CountryCodePicker(
                showCountryOnly: true,
                showOnlyCountryWhenClosed: true,
                hideSearch: true,
                initialSelection: nationality,
                countryFilter: widget.countryFilter,
                dialogSize: widget.dialogSize,
                onChanged: (country) {
                  nationality = country.code;
                  setState(() {});
                }),
          ),
        },
        const SizedBox(height: 32),
        MyDoc(
          builder: (my) => UpdateBirthdayField(user: user),
        ),
        if (widget.occupation) ...{
          const SizedBox(height: 32),
          const Text('Occupation'),
          TextField(
            controller: occupationController,
          ),
        },
        const SizedBox(height: 24),
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
              await my!.update(
                name: nameController.text,
                displayName: nameController.text,
                gender: gender,
                nationality: nationality,
                region: region,
                occupation: occupationController.text,
              );

              if (widget.onUpdate != null) {
                widget.onUpdate!();
              }
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

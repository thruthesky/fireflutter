import 'package:cached_network_image/cached_network_image.dart';
// import 'package:country_code_picker/country_code_picker.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DefaultProfileUpdateForm extends StatefulWidget {
  const DefaultProfileUpdateForm(
      {super.key,
      this.occupation = false,
      this.stateMessage = true,
      this.gender = true,
      this.nationality = false,
      this.region = true,
      this.morePhotos = false,
      this.onUpdate,
      this.countryFilter,
      // this.dialogSize,
      this.regionApiKey,
      this.regionSelectorLangCode = 'ko',
      this.countryPickerTheme});

  final void Function()? onUpdate;
  // use [occupation] to hide the occupation field
  final bool occupation;
  final bool stateMessage;
  final bool gender;
  final bool nationality;
  final bool region;
  // use countryFilter to list only the country you want to display in the screen
  final List<String>? countryFilter;
  // final Size? dialogSize;
  final String? regionApiKey;
  final bool morePhotos;
  final String regionSelectorLangCode;
  final ThemeData? countryPickerTheme;

  @override
  State<DefaultProfileUpdateForm> createState() =>
      DefaultProfileUpdateFormState();
}

class DefaultProfileUpdateFormState extends State<DefaultProfileUpdateForm> {
  double? progress;
  double? morePhotoProgress;
  final nameController = TextEditingController();
  String? nationality;
  String? region;
  final occupationController = TextEditingController();
  final stateMessageController = TextEditingController();
  String? gender;
  List<String> urls = [];
  List<String>? regionCode;

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
      regionCode = region?.split('-');
    }
    if (user.gender != '') {
      gender = user.gender;
    }
    if (user.photoUrls.isNotEmpty) {
      urls = user.photoUrls;
    }
    stateMessageController.text = user.stateMessage;
    occupationController.text = user.occupation;

    dog(user.region);
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
                    title: Text(T.male.tr),
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
                    title: Text(T.female.tr),
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
        const SizedBox(height: 32),
        MyDoc(
          builder: (my) => UpdateBirthdayField(user: my ?? user),
        ),
        if (widget.nationality) ...{
          const SizedBox(
            height: 32,
          ),
          Text(T.nationality.tr),
          Theme(
            data: widget.countryPickerTheme ??
                Theme.of(context).copyWith(
                    inputDecorationTheme:
                        Theme.of(context).inputDecorationTheme.copyWith(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(0),
                            ),
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style:
                          Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(16)),
                              ),
                    )),
            child: SizedBox(
              width: double.infinity,
              child: CountryPicker(
                initialValue: nationality,
                filters: widget.countryFilter,
                search: false,
                headerBuilder: () => const Text('Select your country'),
                onChanged: (v) {
                  nationality = v.alpha2;
                },
              ),
            ),
          ),
        },
        if (widget.region) ...{
          const SizedBox(height: 24),
          Text(T.region.tr),
          // init value
          KoreanSiGunGuSelector(
              languageCode: 'en',
              apiKey: widget.regionApiKey ?? '',
              initSiDoCode: regionCode![0],
              initSiGunGuCode: regionCode![1],
              onChangedSiDoCode: (siDo) {},
              onChangedSiGunGuCode: (siDo, siGunGo) {
                region = "${siDo.code}-${siGunGo.code}";
                setState(() {});
              }),
        },
        if (widget.occupation) ...{
          const SizedBox(height: 32),
          Text(T.occupation.tr),
          TextField(
            controller: occupationController,
          ),
        },
        if (widget.morePhotos) ...{
          const SizedBox(height: 32),
          Text(T.pleaseAddMorePhotos.tr),
          SizedBox(
              height: 16,
              child: Column(
                children: [
                  morePhotoProgress != null && morePhotoProgress!.isNaN == false
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: LinearProgressIndicator(
                            value: progress,
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              )),
          Wrap(
            runAlignment: WrapAlignment.start,
            spacing: 16,
            runSpacing: 16,
            children: [
              // display content for urls
              ...urls.map((url) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        width: 130,
                        height: 130,
                      ),
                    ),
                    // delete image
                    Positioned(
                      top: 4,
                      right: 8,
                      child: GestureDetector(
                        onTap: () async {
                          final re = await confirm(
                              context: context,
                              title: '${'delete'.tr}?',
                              message: '${'doYouWantToDeleteThisPhoto'.tr}?');
                          if (re != true) return;
                          urls.remove(url);
                          await StorageService.instance.delete(url);
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(100),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.delete,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              if (urls.length < 4)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    final String? url = await StorageService.instance.upload(
                      context: context,
                      progress: (p) => setState(() => progress = p),
                      complete: () => setState(() => progress = null),
                    );
                    if (url != null) {
                      setState(() {
                        progress = null;
                        urls.add(url);
                      });
                    }
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(8),
                    child: const Icon(Icons.add),
                  ),
                ),
            ],
          ),
        },
        if (widget.stateMessage) ...{
          const SizedBox(height: 32),
          TextField(
            controller: stateMessageController,
            minLines: 5,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: T.stateMessage.tr,
            ),
          ),
        },
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                errorToast(context: context, message: T.inputName.tr);
                return;
              } else if (widget.gender && gender == null) {
                errorToast(context: context, message: T.pleaseSelectGender.tr);
                return;
              } else if (widget.nationality && nationality == null) {
                errorToast(
                    context: context, message: T.pleaseSelectNationality.tr);
                return;
              } else if (widget.region && region == null) {
                errorToast(context: context, message: T.pleaseSelectRegion.tr);
                return;
              } else if (widget.occupation &&
                  occupationController.text.trim().isEmpty) {
                errorToast(
                    context: context, message: T.pleaseInputOccupation.tr);
                return;
              } else if (widget.morePhotos && urls.isEmpty) {
                errorToast(context: context, message: T.pleaseAddMorePhotos.tr);
                return;
              } else if (widget.stateMessage &&
                  stateMessageController.text.trim().isEmpty) {
                errorToast(
                    context: context, message: T.pleaseInputStateMessage.tr);
                return;
              }
              await my!.update(
                  name: nameController.text,
                  displayName: nameController.text,
                  gender: gender,
                  nationality: nationality,
                  region: region,
                  occupation: occupationController.text,
                  photoUrls: urls,
                  stateMessage: stateMessageController.text);

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

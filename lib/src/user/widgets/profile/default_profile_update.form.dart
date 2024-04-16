import 'package:cached_network_image/cached_network_image.dart';
// import 'package:country_code_picker/country_code_picker.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

typedef FormOption = ({
  bool display,
  bool require,
});

class DefaultProfileUpdateForm extends StatefulWidget {
  const DefaultProfileUpdateForm({
    super.key,
    this.backgroundImage,
    this.birthday,
    this.occupation,
    this.stateMessage,
    this.gender,
    this.countryCode,
    this.region,
    this.morePhotos,
    this.onUpdate,
    this.countryFilter,
    this.countrySearch = false,
    this.koreanAreaLanguageCode = 'ko',
    this.countryPickerTheme,
  });

  final void Function()? onUpdate;
  final FormOption? backgroundImage;
  final FormOption? birthday;
  // use [occupation] to hide the occupation field
  final FormOption? occupation;
  final FormOption? stateMessage;
  final FormOption? gender;
  final FormOption? countryCode;
  final bool countrySearch;
  final FormOption? region;
  final FormOption? morePhotos;

  // use countryFilter to list only the country you want to display in the screen
  final List<String>? countryFilter;

  final String koreanAreaLanguageCode;
  final ThemeData? countryPickerTheme;

  @override
  State<DefaultProfileUpdateForm> createState() =>
      DefaultProfileUpdateFormState();
}

class DefaultProfileUpdateFormState extends State<DefaultProfileUpdateForm> {
  double? progress;
  double? morePhotoProgress;
  final nameController = TextEditingController();
  String? countryCode;
  AreaCode? siDo;
  AreaCode? siGunGu;
  final occupationController = TextEditingController();
  final stateMessageController = TextEditingController();
  String? gender;
  List<String> urls = [];
  List<String>? regionCode;

  User get user => UserService.instance.user!;

  @override
  void initState() {
    super.initState();

    nameController.text = my?.displayName ?? '';
    if (user.countryCode != '') {
      countryCode = user.countryCode;
    }
    if (user.siDo != '') {
      siDo = getSiDo(widget.koreanAreaLanguageCode, user.siDo);
    }

    if (user.siGunGu != '') {
      siGunGu =
          getSiGunGu(widget.koreanAreaLanguageCode, user.siDo, user.siGunGu);
    }

    if (user.gender != '') {
      gender = user.gender;
    }
    if (user.photoUrls.isNotEmpty) {
      urls = user.photoUrls;
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
              /// display backgroundImage
              if (widget.backgroundImage?.display == true)
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
                                      "${User.node}/${user.uid}/${Field.profileBackgroundImageUrl}",
                                  progress: (p) => setState(() => progress = p),
                                  complete: () =>
                                      setState(() => progress = null),
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
                )
              else
                const Center(
                  child: UserAvatarUpdate(
                    radius: 80,
                    delete: false,
                  ),
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
        if (widget.gender?.display == true) ...{
          const SizedBox(height: 32),
          Text(T.genderInProfileUpdate.tr,
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text(T.male.tr),
                  value: 'M',
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: RadioListTile<String>(
                  title: Text(T.female.tr),
                  value: 'F',
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
        },
        const SizedBox(height: 32),
        if (widget.birthday?.require == true)
          MyDoc(
            builder: (my) => BirthdayUpdate(
              label: T.birthdateLabel.tr,
              description: T.birthdateSelectDescription.tr,
            ),
          ),
        if (widget.countryCode?.require == true) ...{
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
                  ),
                ),
            child: SizedBox(
              width: double.infinity,
              child: CountryPicker(
                initialValue: countryCode,
                filters: widget.countryFilter,
                search: widget.countrySearch,
                headerBuilder: () => const Text('Select your country'),
                onChanged: (v) {
                  countryCode = v.alpha2;
                },
              ),
            ),
          ),
        },
        if (widget.occupation?.display == true) ...{
          const SizedBox(height: 32),
          Text(T.occupation.tr),
          TextField(
            controller: occupationController,
            decoration: InputDecoration(
              hintText: T.hintInputOccupation.tr,
            ),
          ),
        },
        if (widget.morePhotos?.display == true) ...{
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
                          await my?.update(photoUrls: urls);
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
        if (widget.stateMessage?.display == true) ...{
          const SizedBox(height: 32),
          Text(T.stateMessageInProfileUpdate.tr,
              style: Theme.of(context).textTheme.labelSmall),
          TextField(
            controller: stateMessageController,
            decoration: InputDecoration(
              hintText: T.hintInputStateMessage.tr,
            ),
          ),
        },
        if (widget.region?.display == true) ...{
          const SizedBox(height: 24),
          Text(T.region.tr),
          // init value
          KoreanSiGunGuSelector(
              languageCode: widget.koreanAreaLanguageCode,
              initSiDoCode: siDo?.code,
              initSiGunGuCode: siGunGu?.code,
              onChangedSiDoCode: (siDo) {
                this.siDo = siDo;
              },
              onChangedSiGunGuCode: (siDo, siGunGu) {
                this.siGunGu = siGunGu;
                dog('siGunGu $siDo , $siGunGu');
                setState(() {});
              }),
        },
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              dog('$siGunGu');
              if (nameController.text.trim().isEmpty) {
                errorToast(context: context, message: T.inputName.tr);
                return;
              } else if (widget.birthday?.require == true &&
                  my!.birthYear == 0) {
                errorToast(context: context, message: T.pleaseInputBirthday.tr);
                return;
              } else if (widget.gender?.require == true && gender == null) {
                errorToast(context: context, message: T.pleaseSelectGender.tr);
                return;
              } else if (widget.countryCode?.require == true &&
                  countryCode == null) {
                errorToast(
                    context: context, message: T.pleaseSelectNationality.tr);
                return;
              } else if (widget.region?.require == true && siGunGu == null) {
                errorToast(context: context, message: T.pleaseSelectRegion.tr);
                return;
              } else if (widget.occupation?.require == true &&
                  occupationController.text.trim().isEmpty) {
                errorToast(
                    context: context, message: T.pleaseInputOccupation.tr);
                return;
              } else if (widget.morePhotos?.require == true && urls.isEmpty) {
                errorToast(context: context, message: T.pleaseAddMorePhotos.tr);
                return;
              } else if (widget.stateMessage?.require == true &&
                  stateMessageController.text.trim().isEmpty) {
                errorToast(
                    context: context, message: T.pleaseInputStateMessage.tr);
                return;
              }
              await my!.update(
                  name: nameController.text,
                  displayName: nameController.text,
                  gender: gender,
                  countryCode: countryCode,
                  siDo: siDo?.code,
                  siGunGu: siGunGu?.code,
                  occupation: occupationController.text,
                  photoUrls: urls,
                  stateMessage: stateMessageController.text);

              if (widget.onUpdate != null) {
                widget.onUpdate!();
              }
              if (context.mounted) toast(context: context, message: T.saved.tr);
            },
            child: Text(
              T.save.tr,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

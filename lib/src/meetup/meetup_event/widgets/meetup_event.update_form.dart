import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeetupEventUpdateForm extends StatefulWidget {
  const MeetupEventUpdateForm({
    super.key,
    required this.event,
  });

  final MeetupEvent event;

  @override
  State<MeetupEventUpdateForm> createState() => _MeetupEventUpdateFormState();
}

class _MeetupEventUpdateFormState extends State<MeetupEventUpdateForm> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? date;
  TimeOfDay? time;

  MeetupEvent? _meetup;
  MeetupEvent get event => _meetup ?? widget.event;

  @override
  void initState() {
    super.initState();

    /// Load event data
    ///
    /// 파마메타로 넘어온 event 을 그대로 사용하면, 업데이트가 올바로 되지 않는 경우가 발생한다.
    /// 확실히 하기 위해서, Firestore 로 부터 로딩을 한다.
    MeetupEvent.get(widget.event.ref).then((value) {
      _meetup = value;
      titleController.text = value.title;
      descriptionController.text = value.description;
      date = value.meetAt;
      if (date != null) {
        date = DateTime(date!.year, date!.month, date!.day);
      }
      if (value.meetAt != null) {
        time = TimeOfDay.fromDateTime(value.meetAt!);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(T.meetupScheduleDateAndTime.tr),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  date = await showDatePicker(
                      context: context,
                      initialDate: date ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)));
                  setState(() {});
                },
                child: Text(T.selectDate.tr),
              ),
              const SizedBox(width: 16),
              if (date != null) Text(DateFormat.yMMMEd().format(date!)),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  time = await showTimePicker(
                    context: context,
                    initialTime: time ?? const TimeOfDay(hour: 0, minute: 0),
                    initialEntryMode: TimePickerEntryMode.inputOnly,
                  );
                  setState(() {});
                },
                child: Text(T.selectTime.tr),
              ),
              const SizedBox(width: 16),
              if (time != null) Text(time!.format(context)),
            ],
          ),
          const SizedBox(height: 24),
          Text(T.meetupSchedulePhoto.tr),
          GestureDetector(
            onTap: () async {
              StorageService.instance.delete(event.photoUrl);
              final url = await StorageService.instance.upload(
                context: context,
                progress: (p0) => print(p0),
                complete: () => print('complete'),
              );
              if (url == null) return;

              await event.update(photoUrl: url);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: MeetupEventDoc(
                event: event,
                builder: (MeetupEvent event) => Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: event.photoUrl.isNullOrEmpty
                      ? Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 100,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: event.photoUrl!,
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
            "  ${T.meetupSchedulePhotoNote.tr}",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 24),
          LabelField(
            controller: titleController,
            label: T.meetupScheduleName.tr,
            description: T.meetupScheduleNameNote.tr,
          ),
          LabelField(
            controller: descriptionController,
            label: T.meetupScheduleDescription.tr,
            description: T.meetupScheduleDescriptionNote.tr,
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          Align(
            child: OutlinedButton(
              onPressed: () async {
                if (date == null || time == null) {
                  error(
                      context: context,
                      message: T.meetupScheduleDateOrTimeMissing.tr);
                  return;
                }
                print(date);

                await event.update(
                  title: titleController.text,
                  description: descriptionController.text,
                  meetAt: date!.add(
                    Duration(hours: time!.hour, minutes: time!.minute),
                  ),
                );
                toast(context: context, message: T.meetupScheduleUpdated.tr);
              },
              child: Text(T.editSchedule.tr),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

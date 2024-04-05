import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeetupUpdateForm extends StatefulWidget {
  const MeetupUpdateForm({
    super.key,
    required this.meetup,
  });

  final Meetup meetup;

  @override
  State<MeetupUpdateForm> createState() => _ClubMeetupUpdateFormState();
}

class _ClubMeetupUpdateFormState extends State<MeetupUpdateForm> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? date;
  TimeOfDay? time;

  Meetup? _meetup;
  Meetup get meetup => _meetup ?? widget.meetup;

  @override
  void initState() {
    super.initState();

    /// Load meetup data
    ///
    /// 파마메타로 넘어온 meetup 을 그대로 사용하면, 업데이트가 올바로 되지 않는 경우가 발생한다.
    /// 확실히 하기 위해서, Firestore 로 부터 로딩을 한다.
    Meetup.get(widget.meetup.ref).then((value) {
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
          const Text('만남 일정 날짜와 시간'),
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
                child: const Text('날짜 선택'),
              ),
              const SizedBox(width: 16),
              if (date != null) Text(DateFormat.yMMMEd('ko').format(date!)),
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
                child: const Text('시간 선택'),
              ),
              const SizedBox(width: 16),
              if (time != null) Text(time!.format(context)),
            ],
          ),
          // Text('Club ID: ${meetup.clubId}'),
          // Text('Meetup ID: ${meetup.id}'),
          // Text('owner uid: ${meetup.uid}'),
          // Text('my Uid: ${UserService.instance.user!.uid}'),

          const SizedBox(height: 24),
          const Text('만남 일정 사진'),
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
                          imageUrl: meetup.photoUrl!,
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
            "  모임 사진을 업로드 해 주세요. 사진 크기: 500x500",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 24),
          LabelField(
            controller: titleController,
            label: '만남 일정 이름',
            description: '오프라인 만남에 대한 이름을 적어주세요.',
          ),
          LabelField(
            controller: descriptionController,
            label: '만남 일정 설명',
            description: '만남 설명을 적어주세요.',
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          Align(
            child: OutlinedButton(
              onPressed: () async {
                if (date == null || time == null) {
                  error(context: context, message: '모임 날짜와 시간을 선택해주세요.');
                  return;
                }
                print(date);

                await meetup.update(
                  title: titleController.text,
                  description: descriptionController.text,
                  meetAt: date!.add(
                    Duration(hours: time!.hour, minutes: time!.minute),
                  ),
                );
                toast(context: context, message: '만남 일정이 수정되었습니다.');
              },
              child: const Text('일정 수정하기'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

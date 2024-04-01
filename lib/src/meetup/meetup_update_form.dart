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

  Meetup get meetup => widget.meetup;

  @override
  void initState() {
    super.initState();

    titleController.text = meetup.title;
    descriptionController.text = meetup.description;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('만남 날짜와 시간'),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)));
                  setState(() {});
                },
                child: const Text('날짜 선택'),
              ),
              if (date != null) Text(DateFormat("yyyy년 MM월 dd일").format(date!)),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  time = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 0, minute: 0),
                    initialEntryMode: TimePickerEntryMode.inputOnly,
                  );
                  setState(() {});
                },
                child: const Text('시간 선택'),
              ),
              if (time != null) Text(time!.format(context))
            ],
          ),
          Text('Club ID: ${meetup.clubId}'),
          Text('Meetup ID: ${meetup.id}'),
          Text('owner uid: ${meetup.uid}'),
          Text('my Uid: ${UserService.instance.user!.uid}'),
          GestureDetector(
            onTap: () async {
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
            label: '오프라인 만남 이름',
            description: '오프라인 만남에 대한 이름을 적어주세요.',
          ),
          LabelField(
            controller: descriptionController,
            label: '만남 설명',
            description: '만남 설명을 적어주세요.',
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          Align(
            child: OutlinedButton(
              onPressed: () async {
                await meetup.update(
                  title: titleController.text,
                  description: descriptionController.text,
                );
                toast(context: context, message: '만남 일정이 수정되었습니다.');
              },
              child: const Text('일정 수정하기'),
            ),
          ),
        ],
      ),
    );
  }
}
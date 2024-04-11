import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class BirthdayPickerDialog extends StatefulWidget {
  const BirthdayPickerDialog({
    super.key,
  });

  @override
  State<BirthdayPickerDialog> createState() => _BirthdayPickerState();
}

class _BirthdayPickerState extends State<BirthdayPickerDialog> {
  int birthYear = 2000;
  int birthMonth = 1;
  int birthDay = 1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        if (my?.birthYear == 0) {
          birthYear = 2000;
        } else {
          birthYear = my!.birthYear;
        }

        if (my?.birthMonth == 0) {
          birthMonth = 1;
        } else {
          birthMonth = my!.birthMonth;
        }

        if (my?.birthDay == 0) {
          birthDay = 1;
        } else {
          birthDay = my!.birthDay;
        }
      });
    });
  }

  decorate(Widget child) {
    return InputDecorator(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.only(right: 8),
        isDense: true,
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Text(
            T.selectBirthDate.tr,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      T.yearInBirthdatePicker.tr,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    decorate(
                      DropdownButton<int>(
                        value: birthYear,
                        isExpanded: true,
                        items: [
                          for (int i = 2020; i >= 1950; i--)
                            birthdayMenuItem(i),
                        ],
                        onChanged: (v) => setState(() => birthYear = v!),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.4),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      T.monthInBirthdatePicker.tr,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    decorate(
                      DropdownButton<int>(
                        value: birthMonth,
                        isExpanded: true,
                        items: [
                          for (int i = 1; i <= 12; i++)
                            DropdownMenuItem(
                              value: i,
                              child: birthdayMenuItem(i),
                            ),
                        ],
                        onChanged: (v) => setState(() => birthMonth = v!),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.4),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      T.dayInBirthdatePicker.tr,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    decorate(
                      DropdownButton<int>(
                        value: birthDay,
                        items: [
                          for (int i = 1; i <= 31; i++)
                            DropdownMenuItem(
                                value: i, child: birthdayMenuItem(i)),
                        ],
                        onChanged: (v) => setState(() => birthDay = v!),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            T.descriptionInBirthdatePicker.tr,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await my?.update(
                birthYear: birthYear,
                birthMonth: birthMonth,
                birthDay: birthDay,
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(T.save.tr),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  birthdayMenuItem(int i) => DropdownMenuItem(
        value: i,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            '$i',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
}

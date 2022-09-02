import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobListOptions extends StatefulWidget {
  const JobListOptions({Key? key, required this.change}) : super(key: key);

  final Function(JobListOptionModel) change;

  @override
  State<JobListOptions> createState() => _JobListOptionsState();
}

class _JobListOptionsState extends State<JobListOptions> {
  final options = JobListOptionModel();

  @override
  Widget build(BuildContext context) {
    final TextStyle optionStyle = TextStyle(fontSize: 13);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: InputDecoration(
                        // labelText: "Company name",
                        isDense: true,
                        contentPadding: EdgeInsets.all(6),
                        hintText: 'Company',
                        hintStyle: optionStyle,
                      ),
                      onChanged: (v) {
                        bounce('companyName', 500, (_) async {
                          print('search via company name');
                          options.companyName = v;
                          widget.change(options);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: options.category,
                      items: [
                        DropdownMenuItem(
                          child: Text('Industry', style: optionStyle),
                          value: '',
                        ),
                        ...Job.categories.entries
                            .map((e) => DropdownMenuItem(
                                  child: Text(e.value, style: optionStyle),
                                  value: e.key,
                                ))
                            .toList(),
                      ],
                      onChanged: (v) {
                        setState(() {
                          options.category = v ?? '';
                        });
                        widget.change(options);
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButton<String>(
                        isExpanded: true,
                        value: options.salary,
                        items: [
                          DropdownMenuItem(
                            child: Text('Salary', style: optionStyle),
                            value: '',
                          ),
                          ...Job.salaries.map(
                            (s) => DropdownMenuItem(
                              child: Text("$s Won", style: optionStyle),
                              value: s,
                            ),
                          )
                        ],
                        onChanged: (s) {
                          setState(() {
                            options.salary = s ?? "";
                          });

                          widget.change(options);
                        }),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: options.siNm,
                      items: [
                        DropdownMenuItem(
                          child: Text('Select location', style: optionStyle),
                          value: '',
                        ),
                        for (final name in Job.areas.keys)
                          DropdownMenuItem(
                            child: Text(name, style: optionStyle),
                            value: name,
                          )
                      ],
                      onChanged: (s) {
                        setState(
                          () {
                            if (options.siNm != s) {
                              options.sggNm = '';
                            }
                            options.siNm = s ?? '';
                          },
                        );

                        widget.change(options);
                      },
                    ),
                  ),
                  if (options.siNm != '') SizedBox(width: 8),
                  if (options.siNm != '')
                    Expanded(
                      flex: 1,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: options.sggNm,
                        items: [
                          DropdownMenuItem(
                            child: Text('Select city/county/gu', style: optionStyle),
                            value: '',
                          ),
                          for (final name
                              in Job.areas[options.siNm]!..sort((a, b) => a.compareTo(b)))
                            DropdownMenuItem(
                              child: Text(name, style: optionStyle),
                              value: name,
                            )
                        ],
                        onChanged: (s) {
                          setState(() {
                            options.sggNm = s ?? '';
                          });

                          widget.change(options);
                        },
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButton<int>(
                        isExpanded: true,
                        value: options.workingHours,
                        items: [
                          DropdownMenuItem(
                            child: Text('Working hours', style: optionStyle),
                            value: -1,
                          ),
                          DropdownMenuItem(
                            child: Text('Flexible'),
                            value: 0,
                          ),
                          DropdownMenuItem(
                            child: Text('1 hour'),
                            value: 1,
                          ),
                          for (int i = 2; i <= 14; i++)
                            DropdownMenuItem(
                              child: Text('$i hours'),
                              value: i,
                            ),
                        ],
                        onChanged: (n) {
                          // print('s; $s');
                          setState(() {
                            options.workingHours = n ?? 0;
                          });

                          widget.change(options);
                        }),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButton<int>(
                        isExpanded: true,
                        value: options.workingDays,
                        items: [
                          DropdownMenuItem(
                            child: Text('Working days', style: optionStyle),
                            value: -1,
                          ),
                          DropdownMenuItem(
                            child: Text('Flexible'),
                            value: 0,
                          ),
                          DropdownMenuItem(
                            child: Text('1 day'),
                            value: 1,
                          ),
                          for (int i = 2; i <= 7; i++)
                            DropdownMenuItem(
                              child: Text('$i days'),
                              value: i,
                            ),
                        ],
                        onChanged: (n) {
                          // print('s; $s');
                          setState(() {
                            options.workingDays = n ?? 0;
                          });

                          widget.change(options);
                        }),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButton<String>(
                        isExpanded: true,
                        value: options.accomodation,
                        items: [
                          DropdownMenuItem(
                            child: Text(
                              'Accomodation?',
                              style: optionStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: '',
                          ),
                          DropdownMenuItem(
                            child: Text('Yes'),
                            value: 'Y',
                          ),
                          DropdownMenuItem(
                            child: Text('No'),
                            value: "N",
                          ),
                        ],
                        onChanged: (n) {
                          // print('s; $s');
                          setState(() {
                            options.accomodation = n ?? '';
                          });

                          widget.change(options);
                        }),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

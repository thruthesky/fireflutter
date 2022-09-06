import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobSeekerListOptions extends StatefulWidget {
  const JobSeekerListOptions({Key? key, required this.change})
      : super(key: key);

  final Function(JobSeekerListOptionsModel) change;

  @override
  State<JobSeekerListOptions> createState() => _JobSeekerListOptionsState();
}

class _JobSeekerListOptionsState extends State<JobSeekerListOptions> {
  final options = JobSeekerListOptionsModel();

  @override
  Widget build(BuildContext context) {
    final TextStyle optionStyle = TextStyle(fontSize: 13);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// job seeker search
          /// locations (province, city)
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: options.siNm,
                  items: [
                    DropdownMenuItem(
                      child: Text('Select location', style: optionStyle),
                      value: '',
                    ),
                    ...Job.areas.entries
                        .map((e) => DropdownMenuItem(
                              child: Text(e.key, style: optionStyle),
                              value: e.key,
                            ))
                        .toList(),
                  ],
                  onChanged: (v) {
                    setState(() {
                      options.siNm = v ?? '';
                      options.sggNm = '';
                    });
                    widget.change(options);
                  },
                ),
              ),
              if (options.siNm.isNotEmpty && options.siNm != 'Sejong') ...[
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: options.sggNm,
                    items: [
                      DropdownMenuItem(
                        child:
                            Text('Select city/county/gu', style: optionStyle),
                        value: '',
                      ),
                      for (final name
                          in Job.areas[options.siNm]!
                            ..sort((a, b) => a.compareTo(b)))
                        DropdownMenuItem(
                          child: Text(name, style: optionStyle),
                          value: name,
                        )
                    ],
                    onChanged: (v) {
                      setState(() {
                        options.sggNm = v ?? '';
                      });
                      widget.change(options);
                    },
                  ),
                )
              ],
            ],
          ),

          /// category (industry)
          DropdownButton<String>(
            isExpanded: true,
            value: options.industry,
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
                options.industry = v ?? '';
              });
              widget.change(options);
            },
          )
        ],
      ),
    );
  }
}

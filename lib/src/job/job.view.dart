import 'package:flutter/material.dart';

import 'package:fireflutter/fireflutter.dart';

/// Job View
///
class JobView extends StatefulWidget {
  const JobView({
    Key? key,
    this.job,
    this.onTapProfilePhoto,
  }) : super(key: key);

  final JobModel? job;

  final Function(String)? onTapProfilePhoto;

  // final Function(int index, List<String> fileList) onImageTap;

  @override
  State<JobView> createState() => _JobViewState();
}

class _JobViewState extends State<JobView> {
  late JobModel job;
  late UserModel user;
  @override
  initState() {
    super.initState();
    job = widget.job!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Posted By',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 8),
            UserDoc(
              uid: job.uid,
              builder: (user) => Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTapProfilePhoto != null
                        ? () => widget.onTapProfilePhoto!(job.uid)
                        : null,
                    child: ProfilePhoto(user: user),
                  ),
                  SizedBox(width: 8),
                  Text(user.displayName),
                ],
              ),
            ),
            Divider(height: 24),
          ],
        ),
        JobViewItem(
          value: job.companyName,
          label: "Company Name",
          dividerTop: false,
        ),
        JobViewItem(
          value: job.mobileNumber,
          label: "Mobile number",
        ),
        JobViewItem(
          value: job.phoneNumber,
          label: "Phone number",
        ),
        JobViewItem(
          value: job.email,
          label: "Email",
        ),
        JobViewItem(
          value: job.aboutUs,
          label: "About Us",
        ),
        JobViewItem(
          value: job.roadAddr,
          label: "Road Address",
        ),
        JobViewItem(
          value: job.detailAddress,
          label: "Detail Address",
        ),
        SizedBox(height: 15),
        Text('Job details',
            style: TextStyle(fontSize: 16, color: Colors.black)),
        SizedBox(height: 10),
        JobViewItem(
          value: Job.categories[job.category] ?? '',
          label: "Job Category",
        ),
        JobViewItem(
          value: job.workingDays == 0
              ? "Flexible"
              : job.workingDays > 0
                  ? '${job.workingDays} days'
                  : '',
          label: "Working Days",
        ),
        JobViewItem(
          value: job.workingHours == 0
              ? "Flexible"
              : job.workingHours > 0
                  ? '${job.workingHours} hours'
                  : '',
          label: "Working Hours",
        ),
        JobViewItem(
          value: "${job.salary} Won",
          label: "Salary",
        ),
        JobViewItem(
          value: "${job.numberOfHiring} available slot",
          label: "Vacant",
        ),
        JobViewItem(
          value: job.withAccomodation == 'Y' ? "Yes" : 'No',
          label: "Accomodation",
        ),
        JobViewItem(
          value: job.description,
          label: "Descriptions",
        ),
        JobViewItem(
          key: UniqueKey(),
          value: job.requirement,
          label: "Requirements and qualifications",
        ),
        JobViewItem(
          key: UniqueKey(),
          value: job.duty,
          label: "Duties and responsibilities",
        ),
        if (job.benefit.isNotEmpty)
          JobViewItem(
            key: UniqueKey(),
            value: job.benefit,
            label: "benefits(free meals, dormitory, transporation, etc)",
          ),
        if (job.files.isNotEmpty) ...[
          Divider(height: 24),
          Text(
            'Attach Images',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 8),
          for (int i = 0; i < job.files.length; i++) ...[
            UploadedImage(
              url: job.files[i],
              width: double.infinity,
            ),
            SizedBox(height: 8)
          ]
        ]
      ],
    );
  }
}

class JobViewItem extends StatelessWidget {
  const JobViewItem({
    Key? key,
    required this.value,
    required this.label,
    this.dividerTop = true,
  }) : super(key: key);

  final String value;
  final String label;
  final bool dividerTop;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dividerTop) Divider(height: 24),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 8),
        Text(value),
      ],
    );
  }
}

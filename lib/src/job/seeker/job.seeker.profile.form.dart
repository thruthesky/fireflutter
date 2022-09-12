import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobSeekerProfileForm extends StatefulWidget {
  JobSeekerProfileForm({
    Key? key,
    required this.onSuccess,
  }) : super(key: key);

  final Function onSuccess;

  @override
  State<JobSeekerProfileForm> createState() => _JobSeekerProfileFormState();
}

class _JobSeekerProfileFormState extends State<JobSeekerProfileForm> {
  final labelStyle = TextStyle(fontSize: 10, color: Colors.blueGrey);
  final _formKey = GlobalKey<FormState>(debugLabel: 'jobSeeker');

  final form = JobSeekerModel(id: UserService.instance.uid!);

  bool loaded = false;
  bool loading = false;
  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
    form
        .load(uid: UserService.instance.uid!)
        .then((x) => setState(() => loaded = true));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        MyDoc(builder: (user) => ProfilePhoto(user: user, size: 100)),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('First Name', style: labelStyle),
                SizedBox(height: 5),
                Text('${UserService.instance.user.firstName}'),
              ],
            ),
            SizedBox(width: 16),

            // Column(
            //   children: [
            //     Text('Middle Name', style: labelStyle),
            //     SizedBox(height: 5),
            //     Text('${UserService.instance.data?.middleName}'),
            //   ],
            // ),
            Column(
              children: [
                Text('Last Name', style: labelStyle),
                SizedBox(height: 5),
                Text('${UserService.instance.user.lastName}'),
              ],
            ),
          ],
        ),
        SizedBox(height: 32),
        Text(
          'We do not expose your number and eamil.\nJob hunters will send you a message in app.',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        Divider(height: 30),
        loaded == false
            ? Container(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    JobFormTextField(
                      label: 'Input Your Proficiency',
                      initialValue: form.proficiency,
                      onChanged: (s) => form.proficiency = s,
                      validator: (s) =>
                          validateFieldValue(s, "* Please enter proficiency."),
                      maxLines: 5,
                    ),
                    SizedBox(height: 16),
                    JobFormTextField(
                      label: "Years of experience",
                      initialValue: form.experiences,
                      onChanged: (s) => form.experiences = s,
                      validator: (s) => validateFieldValue(
                        s,
                        "* Please enter years of experience.",
                      ),
                    ),
                    SizedBox(height: 16),
                    Text("Where do you want to work?",
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: JobFormDropdownField<String>(
                            value: form.siNm,
                            onChanged: (v) => setState(() {
                              form.siNm = v ?? '';
                              form.sggNm = '';
                            }),
                            validator: (v) => validateFieldValue(
                                v, "* Please select location."),
                            items: [
                              DropdownMenuItem(
                                child: Text('Select location'),
                                value: '',
                              ),
                              ...Job.areas.entries
                                  .map((e) => DropdownMenuItem(
                                        child: Text(e.key,
                                            style: TextStyle(fontSize: 14)),
                                        value: e.key,
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                        if (form.siNm.isNotEmpty && form.siNm != 'Sejong') ...[
                          SizedBox(width: 10),
                          Expanded(
                            child: JobFormDropdownField<String>(
                              value: form.sggNm,
                              onChanged: (v) => form.sggNm = v ?? '',
                              validator: (v) => validateFieldValue(
                                v,
                                "* Please select city/county/gu.",
                              ),
                              items: [
                                DropdownMenuItem(
                                  child: Text('Select city/county/gu',
                                      style: TextStyle(fontSize: 14)),
                                  value: '',
                                ),
                                for (final name
                                    in Job.areas[form.siNm]!
                                      ..sort((a, b) => a.compareTo(b)))
                                  DropdownMenuItem(
                                    child: Text(name,
                                        style: TextStyle(fontSize: 14)),
                                    value: name,
                                  )
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                    SizedBox(height: 10),
                    JobFormDropdownField<String>(
                      label: "What industry would you like to work in?",
                      value: form.industry,
                      items: [
                        DropdownMenuItem(
                            child: Text('Select industry'), value: ''),
                        ...Job.categories.entries
                            .map((e) => DropdownMenuItem(
                                  child: Text(e.value),
                                  value: e.key,
                                ))
                            .toList(),
                      ],
                      onChanged: (v) => form.industry = v ?? '',
                      validator: (s) => validateFieldValue(
                        s,
                        "* Please select your desired industry.",
                      ),
                    ),
                    SizedBox(height: 16),
                    JobFormTextField(
                      label: 'What do you expect on your future job?',
                      initialValue: form.comment,
                      onChanged: (s) => form.comment = s,
                      validator: (s) => validateFieldValue(
                        s,
                        "* Please enter your comments or expections about your future job.",
                      ),
                      maxLines: 5,
                    ),
                    SizedBox(height: 16),
                    Text('Show your profile on job seeker listing?'),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<Status>(
                            value: Status.Y,
                            groupValue: Status.values.asNameMap()[form.status],
                            title: Text('Yes'),
                            onChanged: (Status? v) =>
                                setState(() => form.status = v!.name),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<Status>(
                            value: Status.N,
                            groupValue: Status.values.asNameMap()[form.status],
                            title: Text('No'),
                            onChanged: (Status? v) =>
                                setState(() => form.status = v!.name),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    if (loading)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                            child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2)),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ElevatedButton(
                            onPressed: onSubmit, child: Text('UPDATE')),
                      )
                  ],
                ),
              )
      ],
    );
  }

  onSubmit() async {
    setState(() {
      isSubmitted = true;
      loading = true;
    });
    if (UserService.instance.user.profileError.isNotEmpty) {
      setState(() => loading = false);
      throw UserService.instance.user.profileError;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Form incomplete, please check for missing information.')),
      );
      setState(() => loading = false);
      return;
    }

    // print('JobSeekerProfileForm::onSubmit::form');
    // print('${form.toString()}');

    form.update().then((v) {
      widget.onSuccess();
    }).whenComplete(() => setState(() => loading = false));
  }

  String? validateFieldValue(dynamic value, String error) {
    if (isSubmitted) {
      if (value == null) return error;
      if (value is String && value.trim().isEmpty) return error;
      if (value is int && value < 0) return error;
    }
    return null;
  }
}

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import 'package:fireflutter/fireflutter.dart';

enum Status { Y, N }

enum Accomodation { Y, N }

/// Job posting form
///
class JobEditForm extends StatefulWidget {
  const JobEditForm({
    Key? key,
    required this.onCreated,
    required this.onUpdated,
  }) : super(key: key);

  final Function() onCreated;
  final Function() onUpdated;

  @override
  State<JobEditForm> createState() => _JobEditFormState();
}

class _JobEditFormState extends State<JobEditForm> {
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final detailedAddress = TextEditingController();

  AddressModel? address;

  JobModel job = JobModel.empty();

  double uploadProgress = 0;
  bool get uploadLimited => job.files.length >= 5;

  bool isSubmitted = false;

  bool loading = false;

  @override
  initState() {
    super.initState();
    init();
  }

  init() async {
    final snapshot = await Job.jobCol.where('uid', isEqualTo: User.instance.uid).get();
    if (snapshot.size > 0) {
      job = JobModel.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>,
        snapshot.docs.first.id,
      );
      address = AddressModel.fromMap(job.toUpdate);
      detailedAddress.text = job.detailAddress;
      addJobAddress(address!);
      setState(() {});
    }
  }

  /// Display popup and let user choose address
  getAddress() async {
    final _address = await Job.showAddressPopupWindow(context);
    if (_address == null) return;
    address = _address;
    detailedAddress.clear();
    setState(() {});
  }

  addJobAddress(AddressModel addr) {
    job.roadAddr = addr.roadAddr;
    job.korAddr = addr.korAddr;
    job.zipNo = addr.zipNo;
    job.siNm = addr.siNm;
    job.sggNm = addr.sggNm;
  }

  /// Validates string value of a field.
  String? validateFieldValue(dynamic value, String error) {
    if (isSubmitted) {
      if (value == null) return error;
      if (value is String && value.isEmpty) return error;
      if (value is int && value < 0) return error;
    }
    return null;
  }

  String? validateEmailFieldStringValue(String? value) {
    if (isSubmitted == false) return null;
    return EmailValidator.validate(value ?? '')
        ? null
        : "* Please input correct company email address.";
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'To open(or update) a job recuriting post, input short and clear description about your company and the job.',
            style: TextStyle(fontSize: 14, color: Colors.blueGrey),
          ),
          SizedBox(height: 15),

          JobFormTextField(
            label: "Company name",
            initialValue: job.companyName,
            onChanged: (s) => job.companyName = s,
            validator: (v) => validateFieldValue(v, "* Please input company name."),
          ),
          SizedBox(height: 16),

          JobFormTextField(
            label: "Mobile number",
            initialValue: job.mobileNumber,
            onChanged: (s) => job.mobileNumber = s,
            validator: (v) => validateFieldValue(v, "* Please input company mobile number."),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16),

          JobFormTextField(
            label: 'Office phone number number',
            initialValue: job.phoneNumber,
            onChanged: (s) => job.phoneNumber = s,
            validator: (v) => validateFieldValue(v, "* Please input company office phone number."),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16),

          JobFormTextField(
            label: 'Email Address',
            initialValue: job.email,
            onChanged: (s) => job.email = s,
            validator: (v) => validateEmailFieldStringValue(v),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16),

          JobFormTextField(
            label: "About us",
            initialValue: job.aboutUs,
            onChanged: (s) => job.aboutUs = s,
            validator: (v) => validateFieldValue(v, "* Please tell something about your company."),
            maxLines: 5,
          ),
          SizedBox(height: 16),

          GestureDetector(
            onTap: getAddress,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 6),
                  if (address != null) ...[
                    Text('${address?.roadAddr}'),
                    SizedBox(height: 4),
                    Text(
                      '${address?.korAddr}',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (address == null) Text('* Select your address.'),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text('Select', style: TextStyle(fontSize: 14, color: Colors.blue)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isSubmitted && address == null) ...[
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: Text(
                '* Please select an address.',
                style: TextStyle(fontSize: 12, color: Colors.red.shade700),
              ),
            ),
          ],

          /// Company detailed address
          if (address != null) ...[
            SizedBox(height: 9),
            JobFormTextField(
              label: "Input detail address",
              // initialValue: job.detailAddress,
              controller: detailedAddress,
              onChanged: (s) => job.detailAddress = s,
              validator: (v) => validateFieldValue(
                detailedAddress.text,
                "* Please input a detailed address.",
              ),
              maxLines: 2,
            ),
          ],

          Divider(height: 64),

          JobFormDropdownField<String>(
            label: "Job category",
            value: job.category,
            items: [
              DropdownMenuItem(
                child: Text('Select job category'),
                value: '',
              ),
              ...Job.categories.entries
                  .map((e) => DropdownMenuItem(
                        child: Text(e.value),
                        value: e.key,
                      ))
                  .toList(),
            ],
            onChanged: (s) => setState(() => job.category = s ?? ''),
            validator: (s) => validateFieldValue(s, "* Please select job category."),
          ),

          JobFormDropdownField<int>(
            label: "Working days (per week)",
            value: job.workingDays,
            items: [
              DropdownMenuItem(
                child: Text('Select working days'),
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
            onChanged: (n) => setState(() => job.workingDays = n ?? -1),
            validator: (n) => validateFieldValue(
              n,
              "* Please select the number of days to work per week.",
            ),
          ),

          JobFormDropdownField<int>(
            label: "Working hours (per day)",
            value: job.workingHours,
            items: [
              DropdownMenuItem(
                child: Text('Select working hours'),
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
            onChanged: (n) => setState(() => job.workingHours = n ?? -1),
            validator: (n) => validateFieldValue(
              n,
              "* Please select the number of hours to work per day.",
            ),
          ),

          JobFormDropdownField<String>(
            label: "Salary",
            value: job.salary,
            items: [
              DropdownMenuItem(
                child: Text('Select salary'),
                value: '',
              ),
              ...Job.salaries.map(
                (s) => DropdownMenuItem(
                  child: Text("$s Won"),
                  value: s,
                ),
              )
            ],
            onChanged: (s) => setState(() => job.salary = s ?? ""),
            validator: (n) => validateFieldValue(n, "* Please select a salary to offer."),
          ),
          SizedBox(height: 16),

          JobFormTextField(
            label: "Number of hiring",
            initialValue: job.numberOfHiring,
            onChanged: (s) => job.numberOfHiring = s,
            validator: (v) => validateFieldValue(
              v,
              "* Please input number of available slot for hiring.",
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),

          JobFormTextField(
            label: "Job description(details of what workers will do)",
            initialValue: job.description,
            onChanged: (s) => job.description = s,
            validator: (v) => validateFieldValue(v, "* Please describe something about the job."),
            maxLines: 5,
          ),
          SizedBox(height: 16),

          JobFormTextField(
            label: "Requirements and qualifications",
            initialValue: job.requirement,
            onChanged: (s) => job.requirement = s,
            validator: (v) => validateFieldValue(
              v,
              "* Please enumerate the requirements for the job.",
            ),
            maxLines: 5,
          ),
          SizedBox(height: 16),

          JobFormTextField(
            label: "Duties and responsibilities",
            initialValue: job.duty,
            onChanged: (s) => job.duty = s,
            validator: (v) => validateFieldValue(v, "* Please enumerate the duties of the job."),
            maxLines: 5,
          ),
          SizedBox(height: 16),

          JobFormTextField(
            label: "benefits(free meals, dormitory, transporation, etc)",
            initialValue: job.benefit,
            onChanged: (s) => job.benefit = s,
            maxLines: 5,
          ),
          SizedBox(height: 16),

          // Accommodation
          Text('Includes accomodation?'),
          Row(
            children: [
              Expanded(
                child: RadioListTile<Accomodation>(
                  value: Accomodation.Y,
                  groupValue: Accomodation.values.asNameMap()[job.withAccomodation],
                  title: Text('Yes'),
                  onChanged: (Accomodation? v) => setState(() => job.withAccomodation = v!.name),
                ),
              ),
              Expanded(
                child: RadioListTile<Accomodation>(
                  value: Accomodation.N,
                  groupValue: Accomodation.values.asNameMap()[job.withAccomodation],
                  title: Text('No'),
                  onChanged: (Accomodation? v) => setState(() => job.withAccomodation = v!.name),
                ),
              ),
            ],
          ),

          // Eo accommodation

          /// Upload button
          Divider(),
          if (uploadLimited)
            GestureDetector(
              onTap: () => throw 'Image upload is limited to 5 only.',
              child: Row(
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 42,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      '* File upload limit reached.\n* Delete and upload again to replace existing image.',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            FileUploadButton(
              child: Row(
                children: [
                  Icon(Icons.camera_alt, size: 42),
                  SizedBox(width: 10),
                  Text(
                    '* Tap here to upload an image. \n* You can only upload up to 5 images.',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                  ),
                ],
              ),
              type: 'post',
              onUploaded: (url) {
                job.files = [...job.files, url];
                if (mounted)
                  setState(() {
                    uploadProgress = 0;
                  });
              },
              onProgress: (progress) {
                if (mounted) setState(() => uploadProgress = progress);
              },
              // onError: (e) => widget.onError(e),
            ),
          if (uploadProgress > 0) ...[
            SizedBox(height: 8),
            LinearProgressIndicator(value: uploadProgress),
          ],
          if (job.files.isNotEmpty) ...[
            SizedBox(height: 8),
            ImageListEdit(
              files: job.files,
              onDeleted: (url) => setState(() {}),
              // onError: (e) => widget.onError(e),
            ),
          ],

          Divider(),

          Text('Enable or disable this job opening?'),
          Row(
            children: [
              Expanded(
                child: RadioListTile<Status>(
                  value: Status.Y,
                  groupValue: Status.values.asNameMap()[job.status],
                  title: Text('Enable'),
                  onChanged: (Status? v) => setState(() => job.status = v!.name),
                ),
              ),
              Expanded(
                child: RadioListTile<Status>(
                  value: Status.N,
                  groupValue: Status.values.asNameMap()[job.status],
                  title: Text('Disabled'),
                  onChanged: (Status? v) => setState(() => job.status = v!.name),
                ),
              ),
            ],
          ),

          Divider(),

          if (loading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
            )
          else
            ElevatedButton(
              child: Text('SUBMIT'),
              style: ElevatedButton.styleFrom(elevation: 0),
              onPressed: onSubmit,
            )
        ],
      ),
    );
  }

  Future onSubmit() async {
    setState(() {
      isSubmitted = true;
      loading = true;
    });
    if (address == null || !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form incomplete, please check for missing information.')),
      );
      setState(() => loading = false);
      return;
    }

    addJobAddress(address!);
    return await job.edit().then((value) {
      if (job.id == '') {
        widget.onCreated();
      } else {
        widget.onUpdated();
      }
      return value;
    }).whenComplete(
      () => setState(() {
        loading = false;
      }),
    );
  }
}

import 'package:fireflutter/fireflutter.dart';

class JobModel {
  JobModel({
    this.id = '',
    this.uid = '',
    this.companyName = '',
    this.phoneNumber = '',
    this.mobileNumber = '',
    this.email = '',
    this.detailAddress = '',
    this.aboutUs = '',
    this.numberOfHiring = '',
    this.description = '',
    this.requirement = '',
    this.duty = '',
    this.benefit = '',
    this.roadAddr = '',
    this.korAddr = '',
    this.zipNo = '',
    this.siNm = '',
    this.sggNm = '',
    this.emdNm = '',
    this.category = '',
    this.salary = '',
    this.workingDays = -1,
    this.workingHours = -1,
    this.withAccomodation = 'N',
    this.files = const [],
    this.status = 'Y',
    this.createdAt = 0,
    this.updatedAt = 0,
  });

  String id;
  String uid;
  String companyName;
  String phoneNumber;
  String mobileNumber;
  String email;
  String detailAddress;
  String aboutUs;
  String numberOfHiring;
  String description;
  String requirement;
  String duty;
  String benefit;
  String roadAddr;
  String korAddr;
  String zipNo;
  String siNm;
  String sggNm;
  String emdNm;
  String category;
  String salary;
  int workingDays;
  int workingHours;
  String withAccomodation;
  List<String> files;
  String status;

  int createdAt;
  int updatedAt;

  factory JobModel.fromJson(Json json, [String id = '']) {
    final int _days = json['workingDays'] is int
        ? json['workingDays']
        : int.parse(json['workingDays'] ?? '-1');
    final int _hours = json['workingHours'] is int
        ? json['workingHours']
        : int.parse(json['workingHours'] ?? '-1');

    return JobModel(
      id: json['id'] ?? id,
      uid: json['uid'] ?? '',
      companyName: json['companyName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      email: json['email'] ?? '',
      detailAddress: json['detailAddress'] ?? '',
      aboutUs: json['aboutUs'] ?? '',
      numberOfHiring: json['numberOfHiring'] ?? '',
      description: json['description'] ?? '',
      requirement: json['requirement'] ?? '',
      duty: json['duty'] ?? '',
      benefit: json['benefit'] ?? '',
      category: json['category'] ?? '',
      salary: json['salary'] ?? '',
      workingDays: _days,
      workingHours: _hours,
      withAccomodation: json['withAccomodation'] ?? 'N',
      roadAddr: json['roadAddr'] ?? '',
      korAddr: json['korAddr'] ?? '',
      zipNo: json['zipNo'] ?? '',
      siNm: json['siNm'] ?? '',
      sggNm: json['sggNm'] ?? '',
      emdNm: json['emdNm'] ?? '',
      files: List<String>.from(json['files'] ?? []),
      status: json['status'] ?? 'Y',
      createdAt: toInt(json['createdAt']),
      updatedAt: toInt(json['updatedAt']),
    );
  }

  factory JobModel.empty() {
    return JobModel();
  }

  Map<String, dynamic> get toCreate => {
        'companyName': companyName,
        'phoneNumber': phoneNumber,
        'mobileNumber': mobileNumber,
        'email': email,
        'detailAddress': detailAddress,
        'aboutUs': aboutUs,
        'numberOfHiring': numberOfHiring,
        'description': description,
        'requirement': requirement,
        'duty': duty,
        'benefit': benefit,
        'category': category,
        'salary': salary,
        'workingDays': workingDays,
        'workingHours': workingHours,
        'withAccomodation': withAccomodation,
        'roadAddr': roadAddr,
        'korAddr': korAddr,
        'zipNo': zipNo,
        'siNm': siNm,
        'sggNm': sggNm,
        'emdNm': emdNm,
        'files': files,
        'status': status,
      };

  Map<String, dynamic> get toUpdate {
    final data = toCreate;
    data['id'] = id;
    return data;
  }

  // AddressModel get address => AddressModel.fromMap(toMap);

  @override
  String toString() {
    return '''JobModel($toUpdate)''';
  }

  Future edit() async {
    if (id == '') {
      /// TODO job create
      // return await FunctionsApi.instance.request(
      //   'jobCreate',
      //   data: toCreate,
      //   addAuth: true,
      // );
    } else {
      /// TODO job edit
      // return await FunctionsApi.instance.request(
      //   'jobUpdate',
      //   data: toUpdate,
      //   addAuth: true,
      // );
    }
  }
}

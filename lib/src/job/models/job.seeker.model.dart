import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class JobSeekerModel {
  String id;
  String proficiency;
  String experiences;
  String industry;
  String comment;

  String siNm;
  String sggNm;

  String status;

  // int createdAt;
  // int updatedAt;
  Timestamp? createdAt;
  Timestamp? updatedAt;

  JobSeekerModel({
    this.id = '',
    this.proficiency = '',
    this.experiences = '',
    this.industry = '',
    this.comment = '',
    this.siNm = '',
    this.sggNm = '',
    this.status = 'Y',
    this.createdAt,
    this.updatedAt,
  });

  factory JobSeekerModel.fromJson(Map<String, dynamic> json, String id) {
    Timestamp? _createdAt = json['createdAt'] is int
        ? Timestamp.fromMillisecondsSinceEpoch(json['createdAt'] * 1000)
        : json['createdAt'];

    Timestamp? _updatedAt = json['updatedAt'] is int
        ? Timestamp.fromMillisecondsSinceEpoch(json['updatedAt'] * 1000)
        : json['updatedAt'];

    return JobSeekerModel(
      id: id,
      proficiency: json['proficiency'] ?? '',
      experiences: json['experiences'] ?? '',
      industry: json['industry'] ?? '',
      comment: json['comment'] ?? '',
      siNm: json['siNm'] ?? '',
      sggNm: json['sggNm'] ?? '',
      status: json['status'] ?? 'Y',
      // createdAt: json['createdAt'] ?? 0,
      // updatedAt: json['updatedAt'] ?? 0,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
    );
  }

  copyWith(Map<String, dynamic> data) {
    Timestamp? _createdAt = data['createdAt'] is int
        ? Timestamp.fromMillisecondsSinceEpoch(data['createdAt'] * 1000)
        : data['createdAt'];

    Timestamp? _updatedAt = data['updatedAt'] is int
        ? Timestamp.fromMillisecondsSinceEpoch(data['updatedAt'] * 1000)
        : data['updatedAt'];

    proficiency = data['proficiency'] ?? '';
    experiences = data['experiences'] ?? '0';
    industry = data['industry'] ?? '';
    comment = data['comment'] ?? '';
    siNm = data['siNm'] ?? '';
    sggNm = data['sggNm'] ?? '';
    status = data['status'] ?? 'Y';
    // createdAt: data['createdAt'] ?? 0,
    // updatedAt: data['updatedAt'] ?? 0,
    createdAt = _createdAt;
    updatedAt = _updatedAt;
  }

  /// TODO: update backend rules.
  ///
  Future update() async {
    final profile = await load(uid: id);

    final data = {
      ...updateMap,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (profile == null) data['createdAt'] = FieldValue.serverTimestamp();
    log('Job profile update ====> ' + data.toString());
    return await Job.jobSeekerCol.doc(id).set(data);
  }

  /// Get job profile.
  /// It returns null if the document does not exists.
  ///
  Future<JobSeekerModel?> load({required String uid}) async {
    final res = await Job.jobSeekerCol.doc(uid).get();
    if (res.exists == false) return null;
    return JobSeekerModel.fromJson(res.data() as Json, res.id);
  }

  Map<String, dynamic> get updateMap => {
        'proficiency': proficiency,
        'experiences': experiences,
        'industry': industry,
        'comment': comment,
        'siNm': siNm,
        'sggNm': sggNm,
        'status': status,
      };
}

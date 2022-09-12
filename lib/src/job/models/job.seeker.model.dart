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

  int createdAt;
  int updatedAt;

  JobSeekerModel({
    this.id = '',
    this.proficiency = '',
    this.experiences = '',
    this.industry = '',
    this.comment = '',
    this.siNm = '',
    this.sggNm = '',
    this.status = 'Y',
    this.createdAt = 0,
    this.updatedAt = 0,
  });

  factory JobSeekerModel.fromJson(Map<String, dynamic> json, String id) {
    return JobSeekerModel(
      id: id,
      proficiency: json['proficiency'] ?? '',
      experiences: json['experiences'] ?? '',
      industry: json['industry'] ?? '',
      comment: json['comment'] ?? '',
      siNm: json['siNm'] ?? '',
      sggNm: json['sggNm'] ?? '',
      status: json['status'] ?? 'Y',
      createdAt: json['createdAt'] ?? 0,
      updatedAt: json['updatedAt'] ?? 0,
    );
  }

  copyWith(Map<String, dynamic> data) {
    proficiency = data['proficiency'] ?? '';
    experiences = data['experiences'] ?? '0';
    industry = data['industry'] ?? '';
    comment = data['comment'] ?? '';
    siNm = data['siNm'] ?? '';
    sggNm = data['sggNm'] ?? '';
    status = data['status'] ?? 'Y';
    createdAt = data['createdAt'] ?? 0;
    updatedAt = data['updatedAt'] ?? 0;
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

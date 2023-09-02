import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class FirebaseDateTimeConverter implements JsonConverter<DateTime, int> {
  const FirebaseDateTimeConverter();

  @override
  DateTime fromJson(dynamic data) {
    if (data == null) {
      return DateTime.now();
    }
    // The createdAt may be int (from RTDB) or Timestamp (from Fireestore), or null.
    if (data is int) {
      return DateTime.fromMillisecondsSinceEpoch(data);
    }
    if (data is Timestamp) {
      return data.toDate();
    } else {
      return DateTime.now();
    }
  }

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'storage.g.dart';

@JsonSerializable()
class Storage {
  static const String collectionName = 'storages';
  static DocumentReference doc([String? storageId]) => storageCol.doc(storageId);
  final String uid;

  final String type;

  final String url;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic>? data;

  Storage({
    required this.uid,
    required this.type,
    required this.url,
  });

  factory Storage.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Storage.fromJson({
      ...documentSnapshot.data() as Map<String, dynamic>,
      ...{'id': documentSnapshot.id}
    });
  }

  factory Storage.fromJson(Map<String, dynamic> json) => _$StorageFromJson(json)..data = json;
  Map<String, dynamic> toJson() => _$StorageToJson(this);

  static Future<Storage> get(String? storageId) async {
    if (storageId == null) {
      throw Exception('Storage id is null');
    }

    final DocumentSnapshot documentSnapshot = await storageCol.doc(storageId).get();
    if (documentSnapshot.exists == false) {
      throw Exception('Storage  not found');
    }

    return Storage.fromDocumentSnapshot(documentSnapshot);
  }

  static Future<Storage?> create({
    required String url,
    String? type,
    String? contentType, // image/jpeg, image/gif, image/png, image....
    String? fullPath,
    String? name,
    int? size,
    DateTime? timeCreated,
  }) async {
    final Map<String, dynamic> storageData = {
      'uid': myUid!,
      'url': url,
      'type': type ?? StorageType.upload.name,
      'createdAt': FieldValue.serverTimestamp(),
      'contentType': contentType, // image/jpeg, image/gif, image/png, image....
      'fullPath': fullPath,
      'name': name,
      'size': size,
      'timeCreated': timeCreated,
      'isImage': contentType?.startsWith('image') ?? false,
      'isVideo': contentType?.startsWith('video') ?? false,
      'isAudio': contentType?.startsWith('audio') ?? false,
      'isText': contentType?.startsWith('text') ?? false,
      'isApplication': contentType?.startsWith('application') ?? false,
    };
    final storageId = Storage.doc().id;
    await Storage.doc(storageId).set(storageData);

    final storage = Storage.fromJson(
      {
        ...storageData,
        'id': storageId,
        'createdAt': DateTime.now(),
      },
    );

    return storage;
  }

  static delete(String url) {
    storageCol.where('url', isEqualTo: url).get().then((value) {
      for (var element in value.docs) {
        element.reference.delete();
      }
    });
  }

  @override
  String toString() => 'Storage(${toJson()})';
}

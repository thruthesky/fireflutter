import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

/// Get a node data
///
/// Note that, [FirebaseDatabase.instance.get] has a bug. So [once] is being
/// used.
///
/// [path] is the path of the node.
///
/// Example: below will get the value of /settings/abc/path/to/node. If the
/// node does not exist, it will return null.
/// ```
/// final value = await get('/settings/abc/path/to/node');
/// ```
Future<T?> get<T>(String path) async {
  final snapshot = await getSnapshot(path);
  if (!snapshot.exists) {
    return null;
  }
  return snapshot.value as T;
}

Future<DataSnapshot> getSnapshot(String path) async {
  final event = await FirebaseDatabase.instance.ref(path).once(DatabaseEventType.value);
  return event.snapshot;
}

/// Get a list of keys of a node
///
/// [path] is the path of the node.
///
/// ! It returns an empty list if the node does not exist.
Future<List<String>> getKeys(String path) async {
  final snapshot = await getSnapshot(path);
  if (!snapshot.exists) {
    return [];
  }
  final value = snapshot.value;
  if (value is Map) {
    return value.keys.cast<String>().toList();
  }
  return [];
}

/// Set a node data
///
/// This will overwrite any data at this location and all child locations.
///
/// Data types that are allowed are String, boolean, int, double, Map, List.
Future<void> set<T>(String path, dynamic value) async {
  await FirebaseDatabase.instance.ref(path).set(value);
}

/// Update a node data
///
/// Writes multiple values to the Database at once.
///
/// The values argument contains multiple property-value pairs that will be
/// written to the Database together. Each child property can either be a
/// simple property (for example, "name") or a relative path
/// (for example, "name/first") from the current location to the data to
/// update.
///
/// As opposed to the [set] method, [update] can be use to selectively update
/// only the referenced properties at the current location (instead of
/// replacing all the child properties at the current location).
///
/// Note that modifying data with [update] will cancel any pending
/// transactions at that location, so extreme care should be taken if mixing
/// [update] and [runTransaction] to modify the same data.
///
/// Passing null to a [Map] value in [update] will remove the value at the
/// specified location.
Future<void> update(String path, Map<String, Object?> value) async {
  await FirebaseDatabase.instance.ref(path).update(value);
}

/// Toogle a node
///
/// If the node of the [path] does not exist, create it and return true.
/// Warning, if the node exists, then remove it and return false.
///
/// ! NOTE - dont use directly, must be called from model or service
Future<bool> toggle(String path) async {
  final value = await get<bool?>(path);

  final ref = FirebaseDatabase.instance.ref(path);
  if (value == null) {
    await ref.set(true);
    return true;
  } else {
    await ref.remove();
    return false;
  }
}

/// Like other user
///
Future<bool> like(String otherUid) async {
  return await toggle('likes/$otherUid/${myUid!}');
}

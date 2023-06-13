class FireFlutterOptions {
  final bool database;
  final bool firestore;
  final String userPath;
  final String displayName;
  final String photoUrl;
  FireFlutterOptions({
    this.database = false,
    this.firestore = false,
    required this.userPath,
    required this.displayName,
    required this.photoUrl,
  }) : assert(database || firestore, 'One of database or firestore must be true');
}

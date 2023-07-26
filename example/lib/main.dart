import 'package:easychat/easychat.dart';
import 'package:example/firebase_options.dart';
import 'package:example/home.screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    EasyChat.instance.initialize(
      usersCollection: 'users',
      displayNameField: 'displayName',
      photoUrlField: 'photoUrl',
      // onChatRoomFileUpload: (context, room) async {
      //   print("onChatRoomFileUpload: Do your upload here. Then, send a message with the url.");

      //   final re = await showModalBottomSheet<ImageSource>(
      //       context: context, builder: (_) => ChatRoomFileUploadBottomSheet(room: room));
      //   // print('re; $re');
      //   if (re == null) return; // double check
      //   final ImagePicker picker = ImagePicker();

      //   // TODO support video later
      //   final XFile? image = await picker.pickImage(source: re);
      //   if (image == null) {
      //     print('image is null after pickImage()');
      //     return;
      //   }

      //   print(image.path);
      //   print(image.name);

      //   final name = sanitizeFilename(image.name, replacement: '-');

      //   EasyChat.instance.sendMessage(room: room, imageUrl: "https://picsum.photos/id/${name.length}/200/200");
      //   // final file = await EasyChat.instance.pickFile();
      //   // if (file == null) return;
      //   // await EasyChat.instance.sendFile(
      //   //   room: room,
      //   //   file: file,
      //   // );
      // },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyChat Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

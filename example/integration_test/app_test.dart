import 'package:example/firebase_options.dart';
import 'package:example/main.chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ···
  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter',
        (tester) async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Load app widget.
      await tester.pumpWidget(const ChatApp());

      expect(find.text('Entry Screen'), findsOneWidget);
    });
  });
}

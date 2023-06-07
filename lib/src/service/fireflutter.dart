import 'package:fireflutter/src/service/fireflutter_options.dart';

class FireFlutter {
  static FireFlutter? _instance;
  static FireFlutter get instance => _instance ??= FireFlutter._();

  FireFlutterOptions? options;

  FireFlutter._() {
    print('---> FireFlutter constructor');
  }

  init(FireFlutterOptions options) {
    print('---> FireFlutter init');
    this.options = options;
  }
}

import 'package:fireflutter/fireflutter.dart';

class FireFlutter {
  static FireFlutter get instance => _instance ?? (_instance = FireFlutter());
  static FireFlutter? _instance;

  late ErrorCallback error;
  late AlertCallback alert;
  late ConfirmCallback confirm;
  late ToastCallback toast;

  init({
    required AlertCallback alert,
    required ConfirmCallback confirm,
    required ErrorCallback error,
    required ToastCallback toast,
  }) {
    this.error = error;
    this.alert = alert;
    this.confirm = confirm;
    this.toast = toast;
  }
}

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// 사용자 설정이 로드 되거나 변경되면 rebuild 를 하는 위젯
///
///
class MySetting extends StatelessWidget {
  const MySetting({super.key, required this.builder});

  final Function(UserSetting? user) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserSetting?>(
      stream: UserSettingService.instance.changes,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator.adaptive(),
          );
        }
        if (snapshot.hasError) {
          dog('error in MySetting: ${snapshot.error}');
          return const Icon(Icons.error_outline);
        }

        return builder(snapshot.data);
      },
    );
  }
}

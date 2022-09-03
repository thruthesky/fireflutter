import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class PointHistory extends StatefulWidget {
  const PointHistory({
    Key? key,
    required this.year,
    required this.month,
    required this.onError,
  }) : super(key: key);

  final int year;
  final int month;
  final ErrorCallback onError;
  @override
  State<PointHistory> createState() => _PointHistoryState();
}

class _PointHistoryState extends State<PointHistory> {
  List<PointHistoryModel> histories = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    try {
      loading = true;

      /// TODO get history
      // histories = await PointApi.instance.getHistory(year: widget.year, month: widget.month);
      setState(() => loading = false);
    } catch (e, s) {
      // debugPrint(e.toString());
      widget.onError(e.toString(), s);
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: CircularProgressIndicator.adaptive(),
          )
        : histories.length == 0
            ? Center(child: Text("No point history for this month"))
            : ListView.separated(
                itemCount: histories.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  PointHistoryModel history = histories[index];

                  final d = DateTime.fromMillisecondsSinceEpoch(history.timestamp * 1000);
                  return ListTile(
                    title: Text(_text(history)),
                    subtitle: Text(
                      "Point. ${history.point} at ${d.year}-${d.month}-${d.day} ${d.hour}:${d.minute}:${d.second}",
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                },
              );
  }

  _text(PointHistoryModel history) {
    switch (history.eventName) {
      case 'register':
        return 'Registration bonus';
      case 'signIn':
        return 'Daily random bonus';
      case 'postCreate':
        return 'Post creation bonus';
      case 'commentCreate':
        return 'Comment creation bonus';
      case 'extra':
        String str = '';
        if (history.reason == 'jobCreate') str = 'Job openning';
        return str;
      default:
        return history.eventName;
    }
  }
}

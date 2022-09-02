class PointHistoryModel {
  int point;
  int timestamp;
  String eventName;
  String reason;
  String key;

  PointHistoryModel({
    this.point = 0,
    this.timestamp = 0,
    this.eventName = '',
    this.reason = '',
    this.key = '',
  });

  factory PointHistoryModel.fromJson(Map<String, dynamic> data) {
    return PointHistoryModel(
        point: data['point'] ?? 0,
        timestamp: data['timestamp'] ?? 0,
        eventName: data['eventName'] ?? '',
        reason: data['reason'] ?? '',
        key: data['key'] ?? '');
  }
}

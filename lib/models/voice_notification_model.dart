class VoiceNotificationModel {
  final int? id;
  final int? hour;
  final int? minute;
  final String? title;
  final String? body;
  final int? day;
  final int? month;

  VoiceNotificationModel({
    this.id,
    this.hour,
    this.minute,
    this.title,
    this.body,
    this.day,
    this.month,
  });

  // Convert model to Map (Useful for logging or passing to services)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'title': title,
      'body': body,
      'day': day,
      'month': month,
    };
  }

  // Create model from Map
  factory VoiceNotificationModel.fromMap(Map<String, dynamic> map) {
    return VoiceNotificationModel(
      id: map['id'] as int?,
      hour: map['hour'] as int?,
      minute: map['minute'] as int?,
      title: map['title'] as String?,
      body: map['body'] as String?,
      day: map['day'] as int?,
      month: map['month'] as int?,
    );
  }
}
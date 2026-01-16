import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  // Common Fields
  final String? reminderId;
  final String? type; 
  final String? title;
  final String? time;
  final bool? isRead;
  final Timestamp? dateTime;
  final dynamic createdAt;
  final dynamic updatedAt;
  final List<Map<String, dynamic>>? schedule;
  final int? notificationId;
  final Timestamp? scheduledAt;

  // Meeting Specific
  final Timestamp? date;

  // Medical Specific
  final String? medicineName;
  final String? dose;
  final String? duration;
  final String? dateRange;
  final bool? morning;
  final bool? afternoon;
  final bool? evening;
  final bool? night;

  ReminderModel({
    this.reminderId,
    this.type,
    this.title,
    this.time,
    this.isRead,
    this.dateTime,
    this.createdAt,
    this.updatedAt,
    this.date,
    this.medicineName,
    this.dose,
    this.duration,
    this.dateRange,
    this.morning,
    this.afternoon,
    this.evening,
    this.night,
    this.schedule,
    this.notificationId,
    this.scheduledAt,
  });

  /// ---------------- copyWith ----------------
  ReminderModel copyWith({
    String? reminderId,
    String? type,
    String? title,
    String? time,
    bool? isRead,
    Timestamp? dateTime,
    dynamic createdAt,
    dynamic updatedAt,
    Timestamp? date,
    String? medicineName,
    String? dose,
    String? duration,
    String? dateRange,
    bool? morning,
    bool? afternoon,
    bool? evening,
    bool? night,
    List<Map<String, dynamic>>? schedule,
    int? notificationId,
    Timestamp? scheduledAt,
  }) {
    return ReminderModel(
      reminderId: reminderId ?? this.reminderId,
      type: type ?? this.type,
      title: title ?? this.title,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      dateTime: dateTime ?? this.dateTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      date: date ?? this.date,
      medicineName: medicineName ?? this.medicineName,
      dose: dose ?? this.dose,
      duration: duration ?? this.duration,
      dateRange: dateRange ?? this.dateRange,
      morning: morning ?? this.morning,
      afternoon: afternoon ?? this.afternoon,
      evening: evening ?? this.evening,
      night: night ?? this.night,
      schedule: schedule ?? this.schedule,
      notificationId: notificationId ?? this.notificationId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reminderId': reminderId,
      'type': type,
      'title': title,
      'time': time,
      'isRead': isRead ?? false,
      'dateTime': dateTime,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'schedule': schedule,
      if (date != null) 'date': date,
      if (medicineName != null) 'medicineName': medicineName,
      if (dose != null) 'dose': dose,
      if (duration != null) 'duration': duration,
      if (dateRange != null) 'dateRange': dateRange,
      if (morning != null) 'morning': morning,
      if (afternoon != null) 'afternoon': afternoon,
      if (evening != null) 'evening': evening,
      if (night != null) 'night': night,
      if (notificationId != null) 'notificationId': notificationId,
      if (scheduledAt != null) 'scheduledAt': scheduledAt,
    };
  }

  /// fromMap KEPT AS REQUESTED
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      reminderId: map['reminderId'],
      type: map['type'],
      title: map['title'],
      time: map['time'],
      isRead: map['isRead'],
      dateTime: map['dateTime'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      date: map['date'],
      medicineName: map['medicineName'],
      dose: map['dose'],
      duration: map['duration'],
      dateRange: map['dateRange'],
      morning: map['morning'],
      afternoon: map['afternoon'],
      evening: map['evening'],
      night: map['night'],
      schedule: map['shedule'],
      notificationId: map['notificationId'],
      scheduledAt: map['scheduledAt'],
    );
  }
}

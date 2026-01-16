import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderMeetingsModel {
  final String? reminderId;
  final String? type;
  final String? title;
  final Timestamp? date;
  final String? time;
  final bool? isRead;
  final Timestamp? dateTime;
  final dynamic createdAt; 
  final dynamic updatedAt;

  ReminderMeetingsModel({
    this.reminderId,
    this.type,
    this.title,
    this.date,
    this.time,
    this.isRead,
    this.dateTime,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Firestore Document to Model
  factory ReminderMeetingsModel.fromMap(Map<String, dynamic> map) {
    return ReminderMeetingsModel(
      reminderId: map['reminderId'] as String?,
      type: map['type'] as String?,
      title: map['title'] as String?,
      date: map['date'] as Timestamp?,
      time: map['time'] as String?,
      isRead: map['isRead'] as bool?,
      dateTime: map['dateTime'] as Timestamp?,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  // Convert Model to Map for Saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'reminderId': reminderId,
      'type': type,
      'title': title,
      'date': date,
      'time': time,
      'isRead': isRead ?? false,
      'dateTime': dateTime,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }
}
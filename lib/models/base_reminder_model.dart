import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remindus/models/vaccination_record.dart';

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
  final String? bloodPressure;
  final String? heartRate;
  final String? frequency;
  final VaccinationRecord? vaccinationData;
  // Meeting Specific
  final Timestamp? date;

  // Medical Specific
  final String? medicineName;
  final String? dose;
  final String? duration;
  final String? dateRange;
  final List<String>? whenToTake;
  final Timestamp? nextDoseDue;

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
    this.whenToTake,
    this.schedule,
    this.notificationId,
    this.scheduledAt,
    this.bloodPressure,
    this.heartRate,
    this.frequency,
    this.nextDoseDue,
    this.vaccinationData,
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
    List<String>? whenToTake,
    List<Map<String, dynamic>>? schedule,
    int? notificationId,
    Timestamp? scheduledAt,
    String? bloodPressure,
    String? heartRate,
    String? frequency,
    Timestamp? nextDoseDue,
    VaccinationRecord? vaccinationData,
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
      whenToTake: whenToTake ?? this.whenToTake,
      schedule: schedule ?? this.schedule,
      notificationId: notificationId ?? this.notificationId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      heartRate: heartRate ?? this.heartRate,
      frequency: frequency ?? this.frequency,
      nextDoseDue: nextDoseDue ?? this.nextDoseDue,
      vaccinationData: vaccinationData ?? this.vaccinationData,
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
      if (whenToTake != null) 'whenToTake': whenToTake,
      if (notificationId != null) 'notificationId': notificationId,
      if (scheduledAt != null) 'scheduledAt': scheduledAt,
      if (bloodPressure != null) 'bloodPressure': bloodPressure,
      if (heartRate != null) 'heartRate': heartRate,
      if (frequency != null) 'frequency': frequency,
      if (nextDoseDue != null) 'nextDoseDue': nextDoseDue,
      if (vaccinationData != null)
        'vaccinationData': vaccinationData!.toFirestore(),
    };
  }

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
      whenToTake: map['whenToTake'] != null
          ? List<String>.from(map['whenToTake'])
          : null,
      schedule: map['schedule'] != null
          ? (map['schedule'] as List)
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : null,
      notificationId: map['notificationId'],
      scheduledAt: map['scheduledAt'],
      bloodPressure: map['bloodPressure'],
      heartRate: map['heartRate'],
      frequency: map['frequency'],
      nextDoseDue: map['nextDoseDue'],
      vaccinationData: map['vaccinationData'] != null
          ? VaccinationRecord.fromMap(map['vaccinationData'])
          : null,
    );
  }
}

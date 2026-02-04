import 'package:cloud_firestore/cloud_firestore.dart';

class VaccinationRecord {
  final String? id;
  final String? vaccineName;
  final DateTime? dateReceived;
  final String?
  frequency; // e.g., "Annual Booster", "Decade Booster", "Single Course"
  final DateTime? nextDoseDue;
  final String? activeFamilyId;
  final String? reminderId; // Linked reminder document ID

  VaccinationRecord({
    this.id,
    this.vaccineName,
    this.dateReceived,
    this.frequency,
    this.nextDoseDue,
    this.activeFamilyId,
    this.reminderId,
  });

  factory VaccinationRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VaccinationRecord(
      id: doc.id,
      vaccineName: data['vaccineName'] as String?,
      dateReceived: (data['dateReceived'] as Timestamp?)?.toDate(),
      frequency: data['frequency'] as String?,
      nextDoseDue: (data['nextDoseDue'] as Timestamp?)?.toDate(),
      activeFamilyId: data['activeFamilyId'] as String?,
      reminderId: data['reminderId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (vaccineName != null) 'vaccineName': vaccineName,
      if (dateReceived != null)
        'dateReceived': Timestamp.fromDate(dateReceived!),
      if (frequency != null) 'frequency': frequency,
      if (nextDoseDue != null) 'nextDoseDue': Timestamp.fromDate(nextDoseDue!),
      if (activeFamilyId != null) 'activeFamilyId': activeFamilyId,
      if (reminderId != null) 'reminderId': reminderId,
    };
  }

  factory VaccinationRecord.fromMap(Map<String, dynamic> map, {String? docId}) {
    return VaccinationRecord(
      id: docId ?? map['id'] as String?,
      vaccineName: map['vaccineName'] as String?,
      dateReceived: map['dateReceived'] is Timestamp
          ? (map['dateReceived'] as Timestamp).toDate()
          : null,
      frequency: map['frequency'] as String?,
      nextDoseDue: map['nextDoseDue'] is Timestamp
          ? (map['nextDoseDue'] as Timestamp).toDate()
          : null,
      activeFamilyId: map['activeFamilyId'] as String?,
      reminderId: map['reminderId'] as String?,
    );
  }

  VaccinationRecord copyWith({
    String? id,
    String? vaccineName,
    DateTime? dateReceived,
    String? frequency,
    DateTime? nextDoseDue,
    String? activeFamilyId,
    String? reminderId,
  }) {
    return VaccinationRecord(
      id: id ?? this.id,
      vaccineName: vaccineName ?? this.vaccineName,
      dateReceived: dateReceived ?? this.dateReceived,
      frequency: frequency ?? this.frequency,
      nextDoseDue: nextDoseDue ?? this.nextDoseDue,
      activeFamilyId: activeFamilyId ?? this.activeFamilyId,
      reminderId: reminderId ?? this.reminderId,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class VaccinationRecord {
  final String? id;
  final String? vaccineName;
  final DateTime? dateReceived;
  final String?
  frequency; // e.g., "Annual Booster", "Decade Booster", "Single Course"
  final DateTime? nextDoseDue;
  final String? activeFamilyId;

  VaccinationRecord({
    this.id,
    this.vaccineName,
    this.dateReceived,
    this.frequency,
    this.nextDoseDue,
    this.activeFamilyId,
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
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (vaccineName != null) 'vaccineName': vaccineName,
      if (dateReceived != null)
        'dateReceived': Timestamp.fromDate(dateReceived!),
      if (frequency != null) 'frequency': frequency,
      if (nextDoseDue != null) 'nextDoseDue': Timestamp.fromDate(nextDoseDue!),
      if (activeFamilyId != null) 'activeFamilyId': activeFamilyId,
    };
  }

  VaccinationRecord copyWith({
    String? id,
    String? vaccineName,
    DateTime? dateReceived,
    String? frequency,
    DateTime? nextDoseDue,
    String? activeFamilyId,
  }) {
    return VaccinationRecord(
      id: id ?? this.id,
      vaccineName: vaccineName ?? this.vaccineName,
      dateReceived: dateReceived ?? this.dateReceived,
      frequency: frequency ?? this.frequency,
      nextDoseDue: nextDoseDue ?? this.nextDoseDue,
      activeFamilyId: activeFamilyId ?? this.activeFamilyId,
    );
  }
}

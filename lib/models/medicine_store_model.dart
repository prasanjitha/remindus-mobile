import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineStoreModel {
  String? medicineStoreId;
  String name;
  String quantity;
  String? imageUrl;
  DateTime? createdAt;
  String? status;
  bool? isNotified;
  DateTime? lastNotifiedAt;

  MedicineStoreModel({
    this.medicineStoreId,
    required this.name,
    required this.quantity,
    this.imageUrl,
    this.createdAt,
    this.status,
    this.isNotified,
    this.lastNotifiedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicineStoreId': medicineStoreId,
      'name': name,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'status': status,
      'isNotified': isNotified ?? false,
      'lastNotifiedAt': lastNotifiedAt != null ? Timestamp.fromDate(lastNotifiedAt!) : null,
    };
  }

  factory MedicineStoreModel.fromMap(Map<String, dynamic> map) {
    return MedicineStoreModel(
      medicineStoreId: map['medicineStoreId'],
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      status: map['status'],
      isNotified: map['isNotified'] ?? false,
      lastNotifiedAt: (map['lastNotifiedAt'] as Timestamp?)?.toDate(),
    );
  }
}
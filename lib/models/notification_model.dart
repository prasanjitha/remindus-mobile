import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? id;
  final String type; // 'reminder', 'low_stock', 'guardian_invitation'
  final String title;
  final String message;
  final bool isRead;
  final Timestamp createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    this.id,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    Timestamp? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt,
      if (data != null) 'data': data,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String?,
      type: map['type'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: map['createdAt'] as Timestamp,
      data: map['data'] as Map<String, dynamic>?,
    );
  }
}

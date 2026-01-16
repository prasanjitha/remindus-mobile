import 'package:flutter/material.dart';

class Alert {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;

  Alert({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
  });
}
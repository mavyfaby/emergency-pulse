import 'package:flutter/material.dart';

enum AlertType {
  general,
  medical,
  fire,
  theft,
  accident,
  suspicious,
  relief,
  trapped,
  other,
}

extension AlertTypeNameExtension on AlertType {
  String get longName {
    switch (this) {
      case AlertType.general:
        return "General";
      case AlertType.medical:
        return "Medical";
      case AlertType.fire:
        return "Fire";
      case AlertType.theft:
        return "Theft";
      case AlertType.accident:
        return "Accident";
      case AlertType.suspicious:
        return "Suspicious";
      case AlertType.relief:
        return "Food / Water / Shelter";
      case AlertType.trapped:
        return "Trapped";
      case AlertType.other:
        return "Other";
    }
  }
}

extension AlertTypeIconExtension on AlertType {
  IconData get icon {
    switch (this) {
      case AlertType.general:
        return Icons.warning;
      case AlertType.medical:
        return Icons.medical_services;
      case AlertType.fire:
        return Icons.local_fire_department;
      case AlertType.theft:
        return Icons.privacy_tip;
      case AlertType.accident:
        return Icons.car_crash;
      case AlertType.suspicious:
        return Icons.warning_amber;
      case AlertType.relief:
        return Icons.food_bank;
      case AlertType.trapped:
        return Icons.person_2;
      case AlertType.other:
        return Icons.info;
    }
  }
}

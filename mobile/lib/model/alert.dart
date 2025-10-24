import 'package:emergency_pulse/model/alert_action.dart';
import 'package:emergency_pulse/model/alert_type.dart';

class AlertModel {
  final String alertHashId;
  final AlertType alertType;
  final String imei;
  final String name;
  final String address;
  final String contactNo;
  final String lat;
  final String lng;
  final String accuracyMeters;
  final String notes;
  final String deviceModel;
  final String deviceBrand;
  final String deviceVersion;
  final String deviceName;
  final String deviceBatteryLevel;
  final String distance;
  final String createdAt;

  AlertModel({
    required this.alertHashId,
    required this.alertType,
    required this.imei,
    required this.name,
    required this.address,
    required this.contactNo,
    required this.lat,
    required this.lng,
    required this.accuracyMeters,
    required this.notes,
    required this.deviceModel,
    required this.deviceBrand,
    required this.deviceVersion,
    required this.deviceName,
    required this.deviceBatteryLevel,
    required this.distance,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      alertHashId: json['alertHashId'],
      alertType: AlertType.values.firstWhere(
        (e) => e.name == json['alertType'],
      ),
      imei: json['imei'],
      name: json['name'],
      address: json['address'],
      contactNo: json['contactNo'],
      lat: json['lat'],
      lng: json['lng'],
      accuracyMeters: json['accuracyMeters'],
      notes: json['notes'],
      deviceModel: json['deviceModel'],
      deviceBrand: json['deviceBrand'],
      deviceVersion: json['deviceVersion'],
      deviceName: json['deviceName'],
      deviceBatteryLevel: json['deviceBatteryLevel'],
      distance: json['distance'].toString(),
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alertHashId': alertHashId,
      'alertType': alertType.name,
      'imei': imei,
      'name': name,
      'address': address,
      'contactNo': contactNo,
      'lat': lat,
      'lng': lng,
      'accuracyMeters': accuracyMeters,
      'notes': notes,
      'deviceModel': deviceModel,
      'deviceBrand': deviceBrand,
      'deviceVersion': deviceVersion,
      'deviceName': deviceName,
      'deviceBatteryLevel': deviceBatteryLevel,
      'distance': distance,
      'createdAt': createdAt,
    };
  }
}

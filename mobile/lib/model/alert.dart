class AlertModel {
  final String hashId;
  final String imei;
  final String name;
  final String address;
  final String contactNo;
  final String lat;
  final String lng;
  final String notes;
  final String deviceModel;
  final String deviceBrand;
  final String deviceVersion;
  final String deviceName;
  final String? doneAt;
  final String createdAt;

  AlertModel({
    required this.hashId,
    required this.imei,
    required this.name,
    required this.address,
    required this.contactNo,
    required this.lat,
    required this.lng,
    required this.notes,
    required this.deviceModel,
    required this.deviceBrand,
    required this.deviceVersion,
    required this.deviceName,
    this.doneAt,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      hashId: json['hashId'],
      imei: json['imei'],
      name: json['name'],
      address: json['address'],
      contactNo: json['contactNo'],
      lat: json['lat'],
      lng: json['lng'],
      notes: json['notes'],
      deviceModel: json['deviceModel'],
      deviceBrand: json['deviceBrand'],
      deviceVersion: json['deviceVersion'],
      deviceName: json['deviceName'],
      doneAt: json['doneAt'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hashId': hashId,
      'imei': imei,
      'name': name,
      'address': address,
      'contactNo': contactNo,
      'lat': lat,
      'lng': lng,
      'notes': notes,
      'deviceModel': deviceModel,
      'deviceBrand': deviceBrand,
      'deviceVersion': deviceVersion,
      'deviceName': deviceName,
      'doneAt': doneAt,
      'createdAt': createdAt,
    };
  }
}

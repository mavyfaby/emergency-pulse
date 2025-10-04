class AlertModel {
  final String hashId;
  final String uuid;
  final String name;
  final String address;
  final String contactNo;
  final String lat;
  final String lng;
  final String? doneAt;
  final bool hasImage;
  final String createdAt;

  AlertModel({
    required this.hashId,
    required this.uuid,
    required this.name,
    required this.address,
    required this.contactNo,
    required this.lat,
    required this.lng,
    this.doneAt,
    required this.hasImage,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      hashId: json['hashId'],
      uuid: json['uuid'],
      name: json['name'],
      address: json['address'],
      contactNo: json['contactNo'],
      lat: json['lat'],
      lng: json['lng'],
      doneAt: json['doneAt'],
      hasImage: json['hasImage'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hashId': hashId,
      'uuid': uuid,
      'name': name,
      'address': address,
      'contactNo': contactNo,
      'lat': lat,
      'lng': lng,
      'doneAt': doneAt,
      'hasImage': hasImage,
      'createdAt': createdAt,
    };
  }
}

class OfficeLocation {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int allowedRadiusMeters;
  final bool isActive;

  const OfficeLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.allowedRadiusMeters,
    required this.isActive,
  });

  factory OfficeLocation.fromJson(Map<String, dynamic> json) {
    return OfficeLocation(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      allowedRadiusMeters: _parseInt(json['allowed_radius_meters']),
      isActive: json['is_active'] == true,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

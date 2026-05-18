class MineralModel {
  const MineralModel({
    required this.id,
    required this.type,
    required this.weight,
    this.status,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String type;
  final double weight;
  final String? status;
  final double? latitude;
  final double? longitude;

  factory MineralModel.fromJson(Map<String, dynamic> json) {
    return MineralModel(
      id: json['id'] as int,
      type: json['type'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'type': type,
        'weight': weight,
        if (status != null) 'status': status,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}

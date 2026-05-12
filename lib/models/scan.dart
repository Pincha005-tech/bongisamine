class Scan {
  final String type;
  final String value;
  final String time;

  Scan({
    required this.type,
    required this.value,
    required this.time,
  });

  factory Scan.fromJson(Map<String, dynamic> json) {
    return Scan(
      type: json['type'],
      value: json['value'],
      time: json['time'],
    );
  }
}
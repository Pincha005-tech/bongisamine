class Worker {
  final String id;
  final String name;
  final String status;

  Worker({
    required this.id,
    required this.name,
    required this.status,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'],
      name: json['name'],
      status: json['status'],
    );
  }
}
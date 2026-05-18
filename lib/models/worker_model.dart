class WorkerModel {
  const WorkerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.badgeId,
    this.departmentRole,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String role;
  final String badgeId;
  final String? departmentRole;

  String get fullName => '$firstName $lastName'.trim();

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      badgeId: json['badge_id'] as String? ?? '',
      departmentRole: json['department_role'] as String?,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
        'badge_id': badgeId,
        if (departmentRole != null) 'department_role': departmentRole,
      };

  Map<String, dynamic> toUpdateJson() => {
        if (firstName.isNotEmpty) 'first_name': firstName,
        if (lastName.isNotEmpty) 'last_name': lastName,
        if (role.isNotEmpty) 'role': role,
        if (badgeId.isNotEmpty) 'badge_id': badgeId,
        if (departmentRole != null) 'department_role': departmentRole,
      };
}

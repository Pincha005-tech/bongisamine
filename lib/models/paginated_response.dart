class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final List<T> data;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final raw = json['data'];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : <T>[];
    return PaginatedResponse(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      total: json['total'] as int? ?? list.length,
      totalPages: json['total_pages'] as int? ?? 1,
      data: list,
    );
  }
}

class AlertRequest {
  final String center;
  final String radius;
  final String bounds;
  final int? page;
  final int? limit;
  final String? search;
  final String? searchBy;
  final String? sortBy;
  final String? sortDir;
  final bool? excludeResolved;

  AlertRequest({
    required this.center,
    required this.radius,
    required this.bounds,
    this.page,
    this.limit,
    this.search,
    this.searchBy,
    this.sortBy,
    this.sortDir,
    this.excludeResolved,
  });

  String toQuery() {
    final query = <String, String?>{
      "center": center,
      "radius": radius,
      "bounds": bounds,
      "page": page?.toString(),
      "limit": limit?.toString(),
      "search": search,
      "searchBy": searchBy,
      "sortBy": sortBy,
      "sortDir": sortDir,
      "excludeResolved": excludeResolved?.toString(),
    };

    return query.entries
        .where((entry) => entry.value != null)
        .map((entry) => "${entry.key}=${entry.value}")
        .join("&");
  }
}

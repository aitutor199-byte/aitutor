class PaginationService {
  static const int defaultPageSize = 20;

  static Map<String, dynamic> getPaginationParams({
    required int page,
    int pageSize = defaultPageSize,
  }) {
    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;
    return {
      'from': from,
      'to': to,
    };
  }

  static int getTotalPages(int totalCount, {int pageSize = defaultPageSize}) {
    return (totalCount / pageSize).ceil();
  }
}

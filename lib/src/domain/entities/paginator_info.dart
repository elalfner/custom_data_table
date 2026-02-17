/// Paginator information.
///
/// It tells the page that is displaying, the number of total pages, and the
/// number of items that it displays per page.
class PaginatorInfo {
  int? count;
  int? total;

  /// Page number that is displaying.
  int? currentPage;

  int? firstItem;

  /// `true` if tha page that is displaying is not the last one.
  bool? hasMorePages;
  int? lastItem;

  /// Number of total pages.
  int? lastPage;

  /// NUmber of items that are displaying per page.
  int? perPage;

  PaginatorInfo({
    this.count,
    this.total,
    this.currentPage,
    this.firstItem,
    this.hasMorePages,
    this.lastItem,
    this.lastPage,
    this.perPage,
  });

  PaginatorInfo copyWith({
    int? count,
    int? total,
    int? currentPage,
    int? firstItem,
    bool? hasMorePages,
    int? lastItem,
    int? lastPage,
    int? perPage,
  }) =>
      PaginatorInfo(
        count: count ?? this.count,
        total: total ?? this.total,
        currentPage: currentPage ?? this.currentPage,
        firstItem: firstItem ?? this.firstItem,
        hasMorePages: hasMorePages ?? this.hasMorePages,
        lastItem: lastItem ?? this.lastItem,
        lastPage: lastPage ?? this.lastPage,
        perPage: perPage ?? this.perPage,
      );

  factory PaginatorInfo.fromJson(Map<String, dynamic> json) => PaginatorInfo(
        count: json["count"] ?? 0,
        total: json["total"] ?? 0,
        currentPage: json["currentPage"] ?? 0,
        firstItem: json["firstItem"] ?? 0,
        hasMorePages: json["hasMorePages"] ?? false,
        lastItem: json["lastItem"] ?? 0,
        lastPage: json["lastPage"] ?? 0,
        perPage: json["perPage"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "total": total,
        "currentPage": currentPage,
        "firstItem": firstItem,
        "hasMorePages": hasMorePages,
        "lastItem": lastItem,
        "lastPage": lastPage,
        "perPage": perPage,
      };
}

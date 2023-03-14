class PaginatorInfo {
  int? count;
  int? total;
  int? currentPage;
  int? firstItem;
  bool? hasMorePages;
  int? lastItem;
  int? lastPage;
  int? perPage;

  PaginatorInfo({
    this.count = 0,
    this.total = 0,
    this.currentPage = 0,
    this.firstItem = 0,
    this.hasMorePages = false,
    this.lastItem = 0,
    this.lastPage = 0,
    this.perPage = 0,
  });

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

extension PaginatorInfoExtension on PaginatorInfo {
  int get totalPages => lastPage ?? 0;
}

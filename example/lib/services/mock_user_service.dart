import 'dart:math';

import 'package:custom_data_table/custom_data_table.dart';

import '../models/user.dart';

/// Service simulating an asynchronous paginated user API.
class MockUserService {
  static final List<User> _mockUsers = List.generate(
    100,
    (index) {
      final id = index + 1;
      final names = [
        'Alice Smith',
        'Bob Jones',
        'Charlie Brown',
        'Diana Prince',
        'Evan Wright',
        'Fiona Gallagher',
        'George Clark',
        'Hannah Abbott',
        'Ian Malcolm',
        'Julia Roberts',
      ];
      final name = '${names[index % names.length]} #$id';
      final phone = '555-01${(index % 90 + 10).toString().padLeft(2, '0')}';
      final userType = index.isEven ? UserType.admin : UserType.user;

      return User(
        id: id,
        name: name,
        phone: phone,
        userType: userType,
      );
    },
  );

  /// Fetches a paginated slice of users with an artificial delay.
  static Future<({List<User> items, PaginatorInfo paginator})> fetchUsers({
    required int page,
    required int perPage,
    Duration delay = const Duration(milliseconds: 1000),
    bool forceEmpty = false,
  }) async {
    await Future<void>.delayed(delay);

    if (forceEmpty) {
      return (
        items: <User>[],
        paginator: PaginatorInfo(
          currentPage: 1,
          lastPage: 1,
          perPage: perPage,
          total: 0,
        ),
      );
    }

    final total = _mockUsers.length;
    final lastPage = (total / perPage).ceil().clamp(1, double.infinity).toInt();
    final clampedPage = page.clamp(1, lastPage);

    final startIndex = (clampedPage - 1) * perPage;
    final endIndex = min(startIndex + perPage, total);

    final items = startIndex < total
        ? _mockUsers.sublist(startIndex, endIndex)
        : <User>[];

    return (
      items: items,
      paginator: PaginatorInfo(
        currentPage: clampedPage,
        lastPage: lastPage,
        perPage: perPage,
        total: total,
      ),
    );
  }
}

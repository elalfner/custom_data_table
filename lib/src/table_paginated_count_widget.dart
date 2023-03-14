import 'package:flutter/material.dart';

import 'models/paginator_info.dart';

class TablePaginatedCountWidget extends StatelessWidget {
  final PaginatorInfo paginatorInfo;
  final bool loading;

  final VoidCallback? onPressedLast;
  final VoidCallback? onPressedNext;

  const TablePaginatedCountWidget({
    super.key,
    required this.paginatorInfo,
    required this.loading,
    required this.onPressedNext,
    required this.onPressedLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '${paginatorInfo.currentPage} de ${paginatorInfo.totalPages}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          InkWell(
            onTap: paginatorInfo.currentPage! > 1 && !loading
                ? onPressedLast
                : null,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 15,
              color: paginatorInfo.currentPage! <= 1 ? Colors.grey[300] : null,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap:
                paginatorInfo.hasMorePages! && !loading ? onPressedNext : null,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: !paginatorInfo.hasMorePages! ? Colors.grey[300] : null,
            ),
          ),
        ],
      ),
    );
  }
}

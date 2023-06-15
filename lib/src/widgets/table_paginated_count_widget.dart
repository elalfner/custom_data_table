import 'package:flutter/material.dart';

import '../models/paginator_info.dart';

class TablePaginatedCountWidget extends StatelessWidget {
  final PaginatorInfo paginatorInfo;
  final bool loading;

  final VoidCallback? onPressedLast;
  final VoidCallback? onPressedNext;

  final Function(int page)? onSelectedPage;

  const TablePaginatedCountWidget({
    super.key,
    required this.paginatorInfo,
    required this.loading,
    required this.onPressedNext,
    required this.onPressedLast,
    required this.onSelectedPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (paginatorInfo.totalPages > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: paginatorInfo.currentPage,
                icon: const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Icon(Icons.keyboard_arrow_down_rounded),
                ),
                iconSize: 14,
                style: Theme.of(context).textTheme.bodySmall,
                borderRadius: BorderRadius.circular(10),
                underline: const SizedBox(),
                isDense: true,
                items: List.generate(
                  paginatorInfo.totalPages,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  ),
                ),
                onChanged: (value) {
                  if (value == null) return;

                  onSelectedPage?.call(value);
                },
              ),
            ),
          ),
        const SizedBox(width: 5),
        SizedBox(
          width: 50,
          child: Text(
            'de ${paginatorInfo.totalPages}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        InkWell(
          onTap:
              paginatorInfo.currentPage! > 1 && !loading ? onPressedLast : null,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 15,
            color: paginatorInfo.currentPage! <= 1 ? Colors.grey[300] : null,
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap:
              paginatorInfo.currentPage != paginatorInfo.totalPages && !loading
                  ? onPressedNext
                  : null,
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
            color: paginatorInfo.currentPage == paginatorInfo.totalPages ? Colors.grey[300] : null,
          ),
        ),
      ],
    );
  }
}

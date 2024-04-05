import 'package:custom_data_table/l10n/localization_extension.dart';
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
    int? currentPage = paginatorInfo.currentPage;
    int? lastPage = paginatorInfo.lastPage;

    if (currentPage == null || currentPage == 0 || lastPage == null) {
      return const SizedBox();
    }

    if (lastPage == 0) return const SizedBox();

    if (currentPage > lastPage) currentPage = lastPage;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: currentPage,
              icon: const Padding(
                padding: EdgeInsets.only(left: 0),
                child: Icon(Icons.keyboard_arrow_down_rounded),
              ),
              iconSize: 14,
              style: Theme.of(context).textTheme.bodySmall,
              borderRadius: BorderRadius.circular(10),
              underline: const SizedBox(),
              items: List.generate(
                lastPage,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1}'),
                ),
              ),
              onChanged: onSelectedPage == null
                  ? null
                  : (value) {
                      if (value == null) return;

                      onSelectedPage?.call(value);
                    },
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '${context.appLocalizations.ofLabel} $lastPage',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 5),
        IconButton(
          padding: const EdgeInsets.all(5),
          iconSize: 15,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          constraints: const BoxConstraints(),
          onPressed: currentPage > 1 && !loading ? onPressedLast : null,
        ),
        const SizedBox(width: 4),
        IconButton(
          padding: const EdgeInsets.all(5),
          iconSize: 15,
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          constraints: const BoxConstraints(),
          onPressed: currentPage != lastPage && !loading ? onPressedNext : null,
        ),
      ],
    );
  }
}

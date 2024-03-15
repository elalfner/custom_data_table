import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/utils/string_extension.dart';
import 'package:flutter/material.dart';

import 'per_page_widget.dart';
import 'table_paginated_count_widget.dart';

class TableFooter extends StatelessWidget {
  final PaginatorInfo paginatorInfo;

  final Function(int perPage)? onPerPageChange;

  /// Callback that notifies when the previous page button is pressed.
  final VoidCallback? onPreviousPage;

  /// Callback that notifies when the next page button is pressed.
  final VoidCallback? onNextPage;

  final Function(int page)? onSelectedPage;

  final bool small;
  final DataTableThemeData? dataTableTheme;

  const TableFooter({
    super.key,
    required this.paginatorInfo,
    this.onPerPageChange,
    this.onPreviousPage,
    this.onNextPage,
    this.onSelectedPage,
    this.small = false,
    this.dataTableTheme,
  });

  @override
  Widget build(BuildContext context) {
    final footerDecoration = context.dataTableTheme?.footerDecoration ??
        BoxDecoration(
          color: Theme.of(context).cardColor,
        );

    final children = [
      if (paginatorInfo.perPage != null &&
          paginatorInfo.currentPage != null &&
          paginatorInfo.total != null)
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            text: '${context.appLocalizations.showing} '.naturalCapitalized,
            children: [
              TextSpan(
                text: (((paginatorInfo.currentPage! - 1) *
                            paginatorInfo.perPage!) +
                        1)
                    .toString(),
                children: [
                  TextSpan(
                    text: ' ${context.appLocalizations.to} ',
                  ),
                  TextSpan(
                    text: (paginatorInfo.currentPage! * paginatorInfo.perPage! >
                                paginatorInfo.total!
                            ? paginatorInfo.total
                            : paginatorInfo.currentPage! *
                                paginatorInfo.perPage!)
                        .toString(),
                  ),
                  TextSpan(
                    text: ' ${context.appLocalizations.ofLabel} ',
                  ),
                  TextSpan(
                    text: paginatorInfo.total!.toString(),
                    children: [
                      TextSpan(
                        text: ' ${context.appLocalizations.results}',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (paginatorInfo.perPage != null && paginatorInfo.perPage != 0)
            Flexible(
              child: TablePerPageWidget(
                paginatorInfo: paginatorInfo,
                onChange: onPerPageChange,
              ),
            ),
          const SizedBox(width: 10),
          TablePaginatedCountWidget(
            paginatorInfo: paginatorInfo,
            loading: false,
            onPressedLast: onPreviousPage,
            onPressedNext: onNextPage,
            onSelectedPage: onSelectedPage,
          ),
        ],
      )
    ];

    if (small) {
      return Container(
        decoration: footerDecoration,
        padding: EdgeInsets.symmetric(
          horizontal: dataTableTheme?.horizontalMargin ?? 20,
          vertical: 10,
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: children,
        ),
      );
    }

    return Container(
      decoration: footerDecoration,
      padding: EdgeInsets.symmetric(
        horizontal: dataTableTheme?.horizontalMargin ?? 20,
        vertical: 10,
      ),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}

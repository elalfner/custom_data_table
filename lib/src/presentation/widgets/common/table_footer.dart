import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/core/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'per_page_widget.dart';
import 'table_paginated_count_widget.dart';

class TableFooter extends StatefulWidget {
  final PaginatorInfo paginatorInfo;

  final Function(int perPage)? onPerPageChange;

  /// Callback that notifies when the previous page button is pressed.
  final VoidCallback? onPreviousPage;

  /// Callback that notifies when the next page button is pressed.
  final VoidCallback? onNextPage;

  final Function(int page)? onSelectedPage;

  final double? availableWidth;

  const TableFooter({
    super.key,
    required this.paginatorInfo,
    this.onPerPageChange,
    this.onPreviousPage,
    this.onNextPage,
    this.onSelectedPage,
    this.availableWidth,
  });

  @override
  State<TableFooter> createState() => _TableFooterState();
}

class _TableFooterState extends State<TableFooter> {
  @override
  Widget build(BuildContext context) {
    final availableWidth = widget.availableWidth;
    if (availableWidth != null) {
      return content(availableWidth);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return content(constraints.maxWidth);
      },
    );
  }

  Widget content(double availableWidth) {
    final dataTableTheme = context.watchDataTableTheme;

    // `true` if available space is smaller than this value.
    final small = availableWidth < 600;

    final footerDecoration = dataTableTheme?.footerDecoration;

    final paginatorInfo = widget.paginatorInfo;

    final currentPage = widget.paginatorInfo.currentPage;
    final perPage = paginatorInfo.perPage;
    final total = paginatorInfo.total;

    final children = [
      if (perPage != null && currentPage != null && total != null)
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            text: '${context.appLocalizations.showing} '.naturalCapitalized,
            children: [
              TextSpan(
                text: NumberFormat.currency(decimalDigits: 0, symbol: '')
                    .format((((currentPage - 1) * perPage) + 1)),
                children: [
                  TextSpan(
                    text: ' ${context.appLocalizations.to} ',
                  ),
                  TextSpan(
                    text: NumberFormat.currency(decimalDigits: 0, symbol: '')
                        .format(currentPage * perPage > total
                            ? total
                            : currentPage * perPage),
                  ),
                  TextSpan(
                    text: ' ${context.appLocalizations.ofLabel} ',
                  ),
                  TextSpan(
                    text: NumberFormat.currency(decimalDigits: 0, symbol: '')
                        .format(total),
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
        )
      else
        const SizedBox(),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (perPage != null && perPage != 0)
            Flexible(
              child: TablePerPageWidget(
                paginatorInfo: paginatorInfo,
                onChange: widget.onPerPageChange,
              ),
            ),
          const SizedBox(width: 10),
          TablePaginatedCountWidget(
            paginatorInfo: paginatorInfo,
            loading: false,
            onPressedLast: widget.onPreviousPage,
            onPressedNext: widget.onNextPage,
            onSelectedPage: widget.onSelectedPage,
          ),
        ],
      )
    ];

    final padding = dataTableTheme?.footerPadding ??
        const EdgeInsets.symmetric(horizontal: 15, vertical: 5);

    if (small) {
      return Container(
        decoration: footerDecoration,
        padding: padding,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: children,
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: footerDecoration,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}

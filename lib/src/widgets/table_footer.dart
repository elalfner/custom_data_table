import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/utils/string_extension.dart';
import 'package:flutter/material.dart';

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
  final DataTableThemeData? dataTableTheme;

  const TableFooter({
    super.key,
    required this.paginatorInfo,
    this.onPerPageChange,
    this.onPreviousPage,
    this.onNextPage,
    this.onSelectedPage,
    this.availableWidth,
    this.dataTableTheme,
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
    // `true` if available space is smaller than this value.
    final small = availableWidth < 600;

    final footerDecoration = context.dataTableTheme?.footerDecoration ??
        BoxDecoration(
          color: Theme.of(context).cardColor,
        );

    final children = [
      if (widget.paginatorInfo.perPage != null &&
          widget.paginatorInfo.currentPage != null &&
          widget.paginatorInfo.total != null)
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            text: '${context.appLocalizations.showing} '.naturalCapitalized,
            children: [
              TextSpan(
                text: (((widget.paginatorInfo.currentPage! - 1) *
                            widget.paginatorInfo.perPage!) +
                        1)
                    .toString(),
                children: [
                  TextSpan(
                    text: ' ${context.appLocalizations.to} ',
                  ),
                  TextSpan(
                    text: (widget.paginatorInfo.currentPage! *
                                    widget.paginatorInfo.perPage! >
                                widget.paginatorInfo.total!
                            ? widget.paginatorInfo.total
                            : widget.paginatorInfo.currentPage! *
                                widget.paginatorInfo.perPage!)
                        .toString(),
                  ),
                  TextSpan(
                    text: ' ${context.appLocalizations.ofLabel} ',
                  ),
                  TextSpan(
                    text: widget.paginatorInfo.total!.toString(),
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
          if (widget.paginatorInfo.perPage != null &&
              widget.paginatorInfo.perPage != 0)
            Flexible(
              child: TablePerPageWidget(
                paginatorInfo: widget.paginatorInfo,
                onChange: widget.onPerPageChange,
              ),
            ),
          const SizedBox(width: 10),
          TablePaginatedCountWidget(
            paginatorInfo: widget.paginatorInfo,
            loading: false,
            onPressedLast: widget.onPreviousPage,
            onPressedNext: widget.onNextPage,
            onSelectedPage: widget.onSelectedPage,
          ),
        ],
      )
    ];

    if (small) {
      return Container(
        decoration: footerDecoration,
        padding: EdgeInsets.symmetric(
          horizontal: widget.dataTableTheme?.horizontalMargin ?? 20,
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
        horizontal: widget.dataTableTheme?.horizontalMargin ?? 20,
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

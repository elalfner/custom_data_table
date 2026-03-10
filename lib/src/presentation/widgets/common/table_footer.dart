import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/core/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'per_page_widget.dart';
import 'table_paginated_count_widget.dart';

/// A widget that displays the footer of the table.
///
/// This widget is used to display the footer of the table.
///
/// It contains the pagination controls and the per page selector.
class TableFooter extends StatefulWidget {
  /// The paginator info.
  final PaginatorInfo paginatorInfo;

  /// Callback that notifies when the per page value changes.
  final Function(int perPage)? onPerPageChange;

  /// Callback that notifies when the previous page button is pressed.
  final VoidCallback? onPreviousPage;

  /// Callback that notifies when the next page button is pressed.
  final VoidCallback? onNextPage;

  /// Callback that notifies when the selected page changes.
  final Function(int page)? onSelectedPage;

  const TableFooter({
    super.key,
    required this.paginatorInfo,
    this.onPerPageChange,
    this.onPreviousPage,
    this.onNextPage,
    this.onSelectedPage,
  });

  @override
  State<TableFooter> createState() => _TableFooterState();
}

class _TableFooterState extends State<TableFooter> {
  @override
  Widget build(BuildContext context) {
    return content();
  }

  /// Builds the content of the footer.
  Widget content() {
    final dataTableTheme = context.watchDataTableTheme;

    final footerDecoration = dataTableTheme?.footerDecoration;

    final paginatorInfo = widget.paginatorInfo;

    final currentPage = widget.paginatorInfo.currentPage;
    final perPage = paginatorInfo.perPage;
    final total = paginatorInfo.total;

    final padding = dataTableTheme?.footerPadding ??
        const EdgeInsets.symmetric(horizontal: 15, vertical: 5);

    return Container(
      padding: padding,
      decoration: footerDecoration,
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        runSpacing: 2,
        children: [
          if (perPage != null && currentPage != null && total != null)
            resultsNumberWidget(currentPage, perPage, total)
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
                onPreviousPage: widget.onPreviousPage,
                onNextPage: widget.onNextPage,
                onSelectedPage: widget.onSelectedPage,
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Builds the results number widget.
  ///
  /// [currentPage] The current page.
  /// [perPage] The number of items per page.
  /// [total] The total number of items.
  ///
  /// Returns a [RichText] widget that displays the number of results.
  RichText resultsNumberWidget(int currentPage, int perPage, int total) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall,
        children: [
          TextSpan(
            text: NumberFormat.decimalPattern().format(total),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          TextSpan(
            text: ' ${context.appLocalizations.results}. ',
          ),
          TextSpan(
            text: '${context.appLocalizations.showing} '.naturalCapitalized,
          ),
          TextSpan(
            text: NumberFormat.decimalPattern()
                .format((((currentPage - 1) * perPage) + 1)),
          ),
          TextSpan(
            text: ' ${context.appLocalizations.to} ',
          ),
          TextSpan(
            text: NumberFormat.decimalPattern().format(
                currentPage * perPage > total ? total : currentPage * perPage),
          ),
        ],
      ),
    );
  }
}

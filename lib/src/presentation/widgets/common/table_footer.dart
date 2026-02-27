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
        children: [
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
                        text:
                            NumberFormat.currency(decimalDigits: 0, symbol: '')
                                .format(currentPage * perPage > total
                                    ? total
                                    : currentPage * perPage),
                      ),
                      TextSpan(
                        text: ' ${context.appLocalizations.ofLabel} ',
                      ),
                      TextSpan(
                        text:
                            NumberFormat.currency(decimalDigits: 0, symbol: '')
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
        ],
      ),
    );
  }
}

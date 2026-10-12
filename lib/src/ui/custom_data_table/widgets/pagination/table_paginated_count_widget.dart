import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/domain/models/paginator_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'select_page_dialog.dart';

/// Builds the information about the pagination.
///
/// It shows the current page, the last page and the total number of items.
/// It allows to select the number of items per page. Also it allows to select
/// the page to navigate to.
///
/// It contains buttons to navigate to the previous and next page.
class TablePaginatedCountWidget extends StatefulWidget {
  /// The paginator info.
  final PaginatorInfo paginatorInfo;

  /// Whether the data is loading.
  ///
  /// If `true` the navigation buttons will be disabled.
  final bool loading;

  /// The callback to be called when the previous page is pressed.
  final VoidCallback? onPreviousPage;

  /// The callback to be called when the next page is pressed.
  final VoidCallback? onNextPage;

  /// The callback to be called when a page is selected.
  final Function(int page)? onSelectedPage;

  const TablePaginatedCountWidget({
    super.key,
    required this.paginatorInfo,
    required this.loading,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onSelectedPage,
  });

  @override
  State<TablePaginatedCountWidget> createState() =>
      _TablePaginatedCountWidgetState();
}

class _TablePaginatedCountWidgetState extends State<TablePaginatedCountWidget> {
  /// The key of the button that shows the dialog.
  ///
  /// It is used to get the position of the button to show the dialog next to it.
  final buttonKey = GlobalKey();

  /// The width of the dialog.
  final double dialogWidth = 80;

  /// The maximum number of items visible in the dialog.
  final int maxItemsVisible = 5;

  /// The height of each item in the dialog.
  final double itemHeight = 40;

  @override
  Widget build(BuildContext context) {
    int? currentPage = widget.paginatorInfo.currentPage;
    final lastPage = widget.paginatorInfo.lastPage;

    if (currentPage == null ||
        currentPage == 0 ||
        lastPage == null ||
        lastPage == 0) {
      return const SizedBox();
    }

    if (currentPage > lastPage) currentPage = lastPage;

    final canSelect =
        widget.onSelectedPage != null && widget.paginatorInfo.lastPage != 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          key: buttonKey,
          color: !canSelect
              ? null
              : Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(5),
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: !canSelect ? null : showDialogPage,
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Text(
                    NumberFormat.decimalPattern().format(currentPage),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 3),
                  if (canSelect)
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14,
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '${context.appLocalizations.ofLabel} ${NumberFormat.decimalPattern().format(lastPage)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 5),
        IconButton(
          padding: const EdgeInsets.all(5),
          iconSize: 15,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          constraints: const BoxConstraints(),
          onPressed:
              currentPage > 1 && !widget.loading ? widget.onPreviousPage : null,
        ),
        const SizedBox(width: 4),
        IconButton(
          padding: const EdgeInsets.all(5),
          iconSize: 15,
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          constraints: const BoxConstraints(),
          onPressed: currentPage != lastPage && !widget.loading
              ? widget.onNextPage
              : null,
        ),
      ],
    );
  }

  /// Shows the dialog to select a page.
  ///
  /// It shows the dialog next to the button that shows the current page.
  ///
  /// The dialog is a list of pages that can be selected.
  void showDialogPage() {
    // Get the position of the button that shows the current page.
    final box = buttonKey.currentContext?.findRenderObject() as RenderBox?;
    final position = box?.localToGlobal(Offset.zero);

    if (position == null) return;

    final buttonHeight = buttonKey.currentContext?.size?.height;

    final x = position.dx;
    final y = position.dy;

    double height = (widget.paginatorInfo.lastPage ?? 0) * itemHeight;

    final dialogHeight = maxItemsVisible * itemHeight;

    if (height > dialogHeight) height = dialogHeight;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dialog',
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) => Stack(
        children: [
          Positioned(
            top: y - height + (buttonHeight ?? 0),
            left: x,
            child: SizedBox(
              width: dialogWidth,
              height: height,
              child: SelectPageWidget(
                itemHeight: itemHeight,
                maxItemsVisible: maxItemsVisible,
                paginatorInfo: widget.paginatorInfo,
                onChanged: (value) => widget.onSelectedPage?.call(value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

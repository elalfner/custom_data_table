import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

/// A widget that shows a list of pages to select.
///
/// It is used to show a list of pages to select in the dialog.
/// It emulates the behavior of a dropdown. We use a dialog instead of a dropdown
/// because the dropdown lags when there are many items.
class SelectPageWidget extends StatefulWidget {
  /// The height of each item in the list.
  final double itemHeight;

  /// The maximum number of items visible in the list.
  final int maxItemsVisible;

  /// The paginator info.
  final PaginatorInfo paginatorInfo;

  /// The callback that notifies when the selected page changes.
  final ValueChanged<int> onChanged;

  const SelectPageWidget(
      {super.key,
      required this.maxItemsVisible,
      required this.itemHeight,
      required this.paginatorInfo,
      required this.onChanged});

  @override
  State<SelectPageWidget> createState() => _SelectPageWidgetState();
}

class _SelectPageWidgetState extends State<SelectPageWidget> {
  @override
  Widget build(BuildContext context) {
    // The shadow of the dialog. It is different for light and dark themes.
    final shadow = Theme.of(context).brightness == Brightness.light
        ? [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: list(),
        ),
      ),
    );
  }

  /// Builds the list of pages.
  ///
  /// It shows the list of pages to select.
  /// It is a scrollable list that allows to select a page.
  /// It is used to show the list of pages in the dialog.
  ///
  /// The selected page is highlighted and visible.
  Widget list() {
    // The color of the selected page. It is different for light and dark themes.
    final selectedColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black12.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.2);

    return BothDirectionsListViewBuilder(
      startIndex: 0,
      maxItemsVisible: widget.maxItemsVisible,
      initIndex: (widget.paginatorInfo.currentPage ?? 1) - 1,
      lastIndex: (widget.paginatorInfo.lastPage ?? 1) - 1,
      itemBuilder: (context, index) {
        final page = index + 1;
        final selected = page == widget.paginatorInfo.currentPage;

        return SizedBox(
          height: widget.itemHeight,
          child: Material(
            color: selected ? selectedColor : Colors.transparent,
            child: InkWell(
              onTap: () {
                widget.onChanged(page);
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    page.toString(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

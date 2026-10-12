import 'package:custom_data_table/src/domain/models/paginator_info.dart';
import 'package:flutter/material.dart';

import '../both_directions_listview_builder.dart';

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

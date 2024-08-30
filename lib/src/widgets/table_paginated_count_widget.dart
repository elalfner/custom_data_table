import 'package:custom_data_table/custom_data_table.dart';
import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:flutter/material.dart';

class TablePaginatedCountWidget extends StatefulWidget {
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
  State<TablePaginatedCountWidget> createState() =>
      _TablePaginatedCountWidgetState();
}

class _TablePaginatedCountWidgetState extends State<TablePaginatedCountWidget> {
  final buttonKey = GlobalKey();

  final double dialogWidth = 80;

  final int maxItemsVisible = 5;
  final double itemHeight = 40;

  @override
  Widget build(BuildContext context) {
    int? currentPage = widget.paginatorInfo.currentPage;
    int? lastPage = widget.paginatorInfo.lastPage;

    if (currentPage == null || currentPage == 0 || lastPage == null) {
      return const SizedBox();
    }

    if (lastPage == 0) return const SizedBox();

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
                    widget.paginatorInfo.currentPage?.toString() ?? '',
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
          '${context.appLocalizations.ofLabel} $lastPage',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 5),
        IconButton(
          padding: const EdgeInsets.all(5),
          iconSize: 15,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          constraints: const BoxConstraints(),
          onPressed:
              currentPage > 1 && !widget.loading ? widget.onPressedLast : null,
        ),
        const SizedBox(width: 4),
        IconButton(
          padding: const EdgeInsets.all(5),
          iconSize: 15,
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          constraints: const BoxConstraints(),
          onPressed: currentPage != lastPage && !widget.loading
              ? widget.onPressedNext
              : null,
        ),
      ],
    );
  }

  void showDialogPage() {
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

class SelectPageWidget extends StatefulWidget {
  final double itemHeight;
  final int maxItemsVisible;

  final PaginatorInfo paginatorInfo;

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final shadow = Theme.of(context).brightness == Brightness.light
        ? [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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

  Widget list() {
    final selectedColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black12.withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);

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

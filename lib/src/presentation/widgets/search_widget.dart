import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/core/helpers/responsive_helpers.dart';
import 'package:custom_data_table/src/core/utils/debounce.dart';
import 'package:custom_data_table/src/core/utils/string_extension.dart';
import 'package:flutter/material.dart';

import 'package:custom_data_table/src/domain/entities/column_info.dart';
import 'package:custom_data_table/src/domain/entities/filter_item.dart';
import 'package:custom_data_table/src/presentation/widgets/common/dates_filter_chip.dart';
import 'package:custom_data_table/src/presentation/widgets/common/custom_filters.dart';
import 'package:custom_data_table/src/presentation/theme/datatable_theme.dart';

class SearchWidget extends StatefulWidget {
  /// List of columns the table has.
  ///
  /// Each element of the list contains the name of the column, key to identify it.
  final List<ColumnId> columns;

  /// Callback to notify when search fields dropdown has changed.
  ///
  /// Notifies the new search fields to search.
  final Function(List<ColumnId> values) onChangeSearchFilter;
  final ValueChanged<String>? onChangeGeneralSearch;

  final List<FilterSection>? filterSections;
  final Function(List<FilterSection> sections)? onChangeFilters;

  final DateSelection? initialDateFilter;

  final DateTime? firstDate;
  final DateTime? lastDate;

  final ChangeDateCallback? onChangeDateFilter;

  final TextEditingController? generalSearchController;

  final InputDecoration? decoration;

  final String? initialValue;

  const SearchWidget({
    Key? key,
    required this.columns,
    required this.onChangeSearchFilter,
    this.filterSections,
    this.onChangeFilters,
    this.initialDateFilter,
    this.onChangeDateFilter,
    this.onChangeGeneralSearch,
    this.generalSearchController,
    this.decoration,
    this.initialValue,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  ValueNotifier<List<ColumnId>> searchColumnsSelected =
      ValueNotifier<List<ColumnId>>([]);

  late TextEditingController _generalController;

  late TextEditingController _usedController;

  final debouncer = Debouncer(milliseconds: 500);

  bool? showClearButton;

  @override
  void initState() {
    _generalController = TextEditingController(text: widget.initialValue);
    _usedController = widget.generalSearchController ?? _generalController;

    _usedController.addListener(() {
      final showClearButton = _usedController.value.text.isNotEmpty;

      if (this.showClearButton != showClearButton) {
        this.showClearButton = showClearButton;
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _generalController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.screenSize == ScreenSize.small) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.onChangeGeneralSearch != null) ...[
            searchBar(),
            const SizedBox(height: 10),
          ],
          filtersWidget(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: filtersWidget(),
        ),
        if (widget.onChangeGeneralSearch != null)
          Container(
            height: 45,
            width: 300,
            margin: const EdgeInsets.only(bottom: 10),
            child: searchBar(),
          )
      ],
    );
  }

  Widget filtersWidget() {
    return CustomFilters(
      sections: widget.filterSections,
      onChange: widget.onChangeFilters,
      onChangeDateFilter: widget.onChangeDateFilter,
      initialDateFilter: widget.initialDateFilter,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );
  }

  Widget searchBar() {
    final searchColumns =
        widget.columns.where((element) => element.canGeneralSearch).toList();

    final decoration = widget.decoration;

    return Row(
      children: [
        ValueListenableBuilder(
          valueListenable: searchColumnsSelected,
          builder: (context, values, child) {
            return Expanded(
              child: TextField(
                controller: _usedController,
                decoration: (decoration ?? const InputDecoration()).copyWith(
                  prefixIcon:
                      decoration?.prefixIcon ?? const Icon(Icons.search),
                  hintText: values.isNotEmpty
                      ? values.map((e) => e.name).join(', ')
                      : (decoration?.hintText ??
                          context.appLocalizations.searchAdjective
                              .naturalCapitalized),
                  contentPadding: decoration?.contentPadding ?? EdgeInsets.zero,
                  suffixIcon: showClearButton != true
                      ? null
                      : IconButton(
                          onPressed: () {
                            _usedController.clear();
                            widget.onChangeGeneralSearch?.call('');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                ),
                onChanged: (value) => debouncer.run(
                  () => widget.onChangeGeneralSearch?.call(value),
                ),
              ),
            );
          },
        ),
        if (searchColumns.isNotEmpty)
          PopUpField<ColumnId>(
            tooltip: context.appLocalizations.filterSearch.naturalCapitalized,
            allIfEmpty: true,
            items: searchColumns
                .map(
                  (e) => PopUpMenuItem(
                    key: e.key,
                    name: e.name,
                    value: e,
                  ),
                )
                .toList(),
            onChange: (values) {
              searchColumnsSelected.value = values;

              widget.onChangeSearchFilter(values);
            },
            onlyIcon: true,
            icon: CircleAvatar(
              backgroundColor:
                  Theme.of(context).floatingActionButtonTheme.backgroundColor,
              child: Icon(
                Icons.short_text_outlined,
                color:
                    Theme.of(context).floatingActionButtonTheme.foregroundColor,
              ),
            ),
          )
      ],
    );
  }
}

class PopUpField<T> extends StatefulWidget {
  final List<PopUpMenuItem<T>> items;
  final List<PopUpMenuItem<T>>? selectedFields;

  final Function(List<T> values) onChange;

  /// Indica si cuando no se ha seleccionado ningún elemento, deba de tener el valor
  /// de todos los elementos.
  final bool allIfEmpty;

  final bool onlyIcon;

  final Widget? icon;

  final String? tooltip;

  const PopUpField({
    Key? key,
    required this.items,
    required this.onChange,
    this.selectedFields,
    this.allIfEmpty = false,
    this.onlyIcon = false,
    this.icon,
    this.tooltip,
  }) : super(key: key);

  @override
  State<PopUpField<T>> createState() => _PopUpFieldState<T>();
}

class _PopUpFieldState<T> extends State<PopUpField<T>> {
  final GlobalKey _menuKey = GlobalKey();

  List<PopUpMenuItem<T>> get items => widget.items;

  late Map<String, bool> selectedMap;

  List<PopUpMenuItem<T>> get selectedItems {
    final selectedItems =
        items.where((element) => selectedMap[element.key] == true).toList();

    if (selectedItems.isEmpty && widget.allIfEmpty) {
      return items
          .where((element) => selectedMap[element.key] == true)
          .toList();
    }

    return selectedItems
        .where((element) => selectedMap[element.key] == true)
        .toList();
  }

  @override
  void initState() {
    selectedMap = {
      for (final f in widget.selectedFields ?? []) f.key: true,
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onlyIcon) return popUpWidget();

    final inputBorder = Theme.of(context).inputDecorationTheme.border;

    OutlineInputBorder? outlineInputBorder;

    if (inputBorder is OutlineInputBorder) {
      outlineInputBorder = inputBorder;
    }

    return Material(
      color: Theme.of(context).inputDecorationTheme.fillColor,
      borderRadius: outlineInputBorder?.borderRadius,
      child: InkWell(
        borderRadius: outlineInputBorder?.borderRadius,
        onTap: () {
          dynamic state = _menuKey.currentState;
          state.showButtonMenu();
        },
        child: Container(
          height: 52,
          padding: const EdgeInsets.only(left: 15, right: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  (widget.allIfEmpty
                          ? selectedItems.isEmpty
                          : selectedItems.length == items.length)
                      ? context.appLocalizations.all.naturalCapitalized
                      : selectedItems.map((e) => e.name).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              popUpWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget popUpWidget() {
    return PopupMenuButton<PopUpMenuItem<T>>(
      key: _menuKey,
      icon: widget.icon ?? const Icon(Icons.keyboard_arrow_down),
      tooltip: widget.tooltip,
      splashRadius: 20,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      onSelected: (value) {
        selectedMap[value.key] = !(selectedMap[value.key] ?? false);

        setState(() {});

        widget.onChange(
          selectedItems.map((e) => e.value).toList(),
        );

        setState(() {});
      },
      itemBuilder: (BuildContext context) => widget.items
          .map(
            (e) => CheckedPopupMenuItem<PopUpMenuItem<T>>(
              value: e,
              checked: selectedMap[e.key] == true,
              child: Text(e.name),
            ),
          )
          .toList(),
    );
  }
}

class PopUpMenuItem<T> {
  final String key;
  final String name;

  final T value;

  PopUpMenuItem({
    required this.key,
    required this.name,
    required this.value,
  });
}

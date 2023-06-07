import 'package:custom_data_table/src/helpers/responsive_helpers.dart';
import 'package:custom_data_table/src/utils/debounce.dart';
import 'package:flutter/material.dart';

import '../custom_data_table.dart';
import 'widgets/dates_filter_chip.dart';

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
  final List<FilterSection>? selectedFilters;
  final Function(List<FilterSection> sections)? onChangeFilters;

  final bool today;
  final DateTime? selectedMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final ChangeDateCallback? onChangeDateFilter;

  final TextEditingController? generalSearchController;

  const SearchWidget({
    Key? key,
    required this.columns,
    required this.onChangeSearchFilter,
    this.filterSections,
    this.selectedFilters,
    this.onChangeFilters,
    this.today = false,
    this.selectedMonth,
    this.startDate,
    this.endDate,
    this.onChangeDateFilter,
    this.onChangeGeneralSearch,
    this.generalSearchController,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  ValueNotifier<List<ColumnId>> searchColumnsSelected =
      ValueNotifier<List<ColumnId>>([]);

  bool today = false;
  DateTime? selectedMonth;
  DateTime? startDate;
  DateTime? endDate;

  final TextEditingController _generalController = TextEditingController();

  final debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    if (context.screenSize == ScreenSize.small) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          searchBar(),
          const SizedBox(height: 10),
          CustomFilters(
            sections: widget.filterSections,
            selectedFilters: widget.selectedFilters,
            onChange: widget.onChangeFilters,
            onChangeDateFilter: widget.onChangeDateFilter,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: CustomFilters(
            sections: widget.filterSections,
            selectedFilters: widget.selectedFilters,
            onChange: widget.onChangeFilters,
            onChangeDateFilter: widget.onChangeDateFilter,
          ),
        ),
        SizedBox(
          height: 45,
          width: 300,
          child: searchBar(),
        )
      ],
    );
  }

  Widget searchBar() {
    final controller = widget.generalSearchController ?? _generalController;

    final searchColumns =
        widget.columns.where((element) => element.canSearch).toList();

    return Row(
      children: [
        ValueListenableBuilder(
          valueListenable: searchColumnsSelected,
          builder: (context, values, child) {
            return Expanded(
              child: TextField(
                controller: widget.generalSearchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: values.isNotEmpty
                      ? values.map((e) => e.name).join(', ')
                      : 'Búsqueda',
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: controller.value.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            controller.clear();
                            widget.onChangeGeneralSearch?.call('');
                            setState(() {});
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
            tooltip: 'Filtrar búsqueda',
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
                      ? 'Todos'
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

import 'package:custom_data_table/src/helpers/responsive_helpers.dart';
import 'package:flutter/material.dart';

import '../custom_data_table.dart';

class SearchWidget extends StatefulWidget {
  /// List of columns the table has.
  ///
  /// Each element of the list contains the name of the column, key to identify it.
  final List<ColumnId> columns;

  /// List of applied filters.
  final List<FilterItem>? filterItems;

  /// Callback to notify when search fields dropdown has changed.
  ///
  /// Notifies the new search fields to search.
  final Function(List<ColumnId> values) onChangeSearchFields;

  /// Callback to notify when filter button es pressed.
  final VoidCallback? onFilterButtonPressed;

  /// Callback to notify when a filter element has been pressed to be removed from the filters list.
  ///
  /// [filterItem] item to be removed from the list.
  final Function(FilterItem filterItem) onFilterDeleted;

  const SearchWidget({
    Key? key,
    required this.columns,
    required this.onChangeSearchFields,
    this.filterItems,
    this.onFilterButtonPressed,
    required this.onFilterDeleted,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  @override
  Widget build(BuildContext context) {
    if (context.screenSize == ScreenSize.small) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          searchBar(),
          const SizedBox(height: 10),
          filtersWidget(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: filtersWidget(),
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
    return const TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: 'Búsqueda',
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget filtersWidget() {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (final filter in widget.filterItems!)
          Chip(
            elevation: 1,
            label:
                Text('${filter.columnInfo?.name ?? ''}: ${filter.filterName}'),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () => widget.onFilterDeleted(filter),
          ),
        if (widget.onFilterButtonPressed != null)
          ActionChip(
            elevation: 1,
            label: const Text(
              'Más filtros',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            avatar: const Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: widget.onFilterButtonPressed,
          ),
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

  const PopUpField({
    Key? key,
    required this.items,
    required this.onChange,
    this.selectedFields,
    this.allIfEmpty = false,
    this.onlyIcon = false,
    this.icon,
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

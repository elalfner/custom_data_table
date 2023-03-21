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
    return LayoutBuilder(builder: (_, constraints) {
      final availableWidth = constraints.maxWidth;

      final small = availableWidth < 500;

      return Container(
        decoration: small
            ? null
            : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff364258).withOpacity(0.03),
                    blurRadius: 9.0,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
        padding: small
            ? null
            : const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!small)
                        Text(
                          '¿Estás buscando algo?',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      const SizedBox(height: 5),
                      const TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Búsqueda',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: small ? null : 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!small)
                        Text(
                          'Campos a buscar',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      const SizedBox(height: 5),
                      PopUpField<ColumnId>(
                        allIfEmpty: true,
                        items: widget.columns
                            .map(
                              (e) => PopUpMenuItem(
                                key: e.key,
                                name: e.name,
                                value: e,
                              ),
                            )
                            .toList(),
                        onChange: widget.onChangeSearchFields,
                        onlyIcon: small,
                        icon: !small
                            ? null
                            : const CircleAvatar(
                                child: Icon(Icons.short_text_outlined),
                              ),
                      )
                    ],
                  ),
                ),
                if (widget.onFilterButtonPressed != null && !small) ...[
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      Text(
                        '',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      FloatingActionButton.small(
                        elevation: 0,
                        onPressed: widget.onFilterButtonPressed,
                        heroTag: 'Filter',
                        child: const Icon(Icons.filter_list),
                      ),
                    ],
                  ),
                ]
              ],
            ),
            const SizedBox(height: 5),
            if (widget.filterItems?.isNotEmpty == true && !small)
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final filter in widget.filterItems!)
                    Chip(
                      elevation: 1,
                      label: Text(
                          '${filter.columnInfo?.name ?? ''}: ${filter.filterName}'),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 14,
                      ),
                      onDeleted: () => widget.onFilterDeleted(filter),
                    ),
                ],
              )
          ],
        ),
      );
    });
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

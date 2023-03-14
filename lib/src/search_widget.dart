import 'package:flutter/material.dart';

import '../custom_data_table.dart';

class SearchWidget extends StatefulWidget {
  final List<ColumnInfo> columns;
  final List<FilterItem>? filterItems;

  final Function(List<ColumnInfo> values) onChangeSearchFields;

  final VoidCallback? onFilterPressed;
  final Function(FilterItem filterItem) onFilterDeleted;

  const SearchWidget({
    Key? key,
    required this.columns,
    required this.onChangeSearchFields,
    this.filterItems,
    this.onFilterPressed,
    required this.onFilterDeleted,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  List<ColumnInfo> selectedMenu = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Estás buscando algo?',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 5),
                    const TextField(
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Busca por alguno de los campos'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campos a buscar',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 5),
                    PopUpField<ColumnInfo>(
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
                    )
                  ],
                ),
              ),
              if (widget.onFilterPressed != null) ...[
                const SizedBox(width: 10),
                Column(
                  children: [
                    Text(
                      '',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    FloatingActionButton.small(
                      elevation: 0,
                      onPressed: widget.onFilterPressed,
                      heroTag: 'Filter',
                      child: const Icon(Icons.filter_list),
                    ),
                  ],
                ),
              ]
            ],
          ),
          const SizedBox(height: 5),
          if (widget.filterItems?.isNotEmpty == true)
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final filter in widget.filterItems!)
                  Chip(
                    elevation: 1,
                    label: Text('${filter.fieldName}: ${filter.filterName}'),
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
  }
}

class PopUpField<T> extends StatefulWidget {
  final List<PopUpMenuItem<T>> items;
  final List<PopUpMenuItem<T>>? selectedFields;

  final Function(List<T> values) onChange;

  const PopUpField(
      {Key? key,
      required this.items,
      required this.onChange,
      this.selectedFields})
      : super(key: key);

  @override
  State<PopUpField<T>> createState() => _PopUpFieldState<T>();
}

class _PopUpFieldState<T> extends State<PopUpField<T>> {
  final GlobalKey _menuKey = GlobalKey();

  List<PopUpMenuItem<T>> get items => widget.items;

  late Map<String, bool> selectedMap;

  List<PopUpMenuItem<T>> get selectedItems => selectedMap.isEmpty
      ? items
      : items.where((element) => selectedMap[element.key] == true).toList();

  @override
  void initState() {
    selectedMap = {
      for (final f in widget.selectedFields ?? []) f.key: true,
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  selectedMap.isEmpty || selectedItems.length == items.length
                      ? 'Todos'
                      : selectedItems.map((e) => e.name).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<PopUpMenuItem<T>>(
                key: _menuKey,
                icon: const Icon(Icons.keyboard_arrow_down),
                splashRadius: 20,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                onSelected: (value) {
                  selectedMap[value.key] = !(selectedMap[value.key] ?? false);

                  setState(() {});

                  widget.onChange(selectedItems.map((e) => e.value).toList());

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
              ),
            ],
          ),
        ),
      ),
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

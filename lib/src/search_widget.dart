import 'package:custom_data_table/src/helpers/responsive_helpers.dart';
import 'package:custom_data_table/src/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../custom_data_table.dart';
import 'filters/timeFilter.dart';

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

  final Function(
          bool today, DateTime? month, DateTime? startDate, DateTime? endDate)?
      onChangeDateFilter;

  const SearchWidget({
    Key? key,
    required this.columns,
    required this.onChangeSearchFields,
    this.filterItems,
    this.onFilterButtonPressed,
    required this.onFilterDeleted,
    this.onChangeDateFilter,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  ValueNotifier<List<ColumnId>> searchFieldsSelected =
      ValueNotifier<List<ColumnId>>([]);

  bool today = false;
  DateTime? selectedMonth;
  DateTime? startDate;
  DateTime? endDate;

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
    return Row(
      children: [
        ValueListenableBuilder(
          valueListenable: searchFieldsSelected,
          builder: (context, values, child) {
            return Expanded(
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: values.isEmpty
                      ? 'Búsqueda'
                      : values.map((e) => e.name).join(', '),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            );
          },
        ),
        PopUpField<ColumnId>(
          tooltip: 'Filtrar búsqueda',
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
          onChange: (values) {
            searchFieldsSelected.value = values;

            widget.onChangeSearchFields(values);
          },
          onlyIcon: true,
          icon: const CircleAvatar(
            child: Icon(Icons.short_text_outlined),
          ),
        )
      ],
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
        if (today)
          Chip(
            elevation: 1,
            label: const Text('Sólo Hoy'),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () => setState(() {
              today = false;
            }),
          ),
        if (selectedMonth != null)
          Chip(
            elevation: 1,
            label: Text(DateFormat.yMMMM().format(selectedMonth!)),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () => setState(() {
              selectedMonth = null;
            }),
          ),
        if (startDate != null && endDate != null)
          Chip(
            elevation: 1,
            label: Text(
                '${DateFormat.yMd().add_Hm().format(startDate!)} - ${DateFormat.yMd().add_Hm().format(endDate!)}'),
            deleteIcon: const Icon(
              Icons.close,
              size: 14,
            ),
            onDeleted: () => setState(() {
              startDate = null;
              endDate = null;
            }),
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
        if (widget.onChangeDateFilter != null)
          ActionChip(
            elevation: 1,
            label: const Text(
              'Escoger fechas',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            avatar: const Icon(
              Icons.calendar_month,
              color: Colors.white,
            ),
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () async {
              bool today = this.today;

              DateTime? selectedMonth = this.selectedMonth;

              bool period = this.startDate != null && this.endDate != null;

              DateTime startDate = this.startDate ?? DateTime.now().onlyDate;

              DateTime endDate = this.endDate ??
                  DateTime.now().onlyDate.add(
                        const Duration(hours: 23, minutes: 59, seconds: 59),
                      );

              await showModalBottomSheet(
                context: context,
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  minWidth: 500,
                ),
                builder: (_) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      final thisYear =
                          selectedMonth?.year == DateTime.now().year;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Día'),
                            const SizedBox(height: 5),
                            ChoiceChip(
                              label: const Text('Hoy'),
                              selected: today,
                              onSelected: (value) {
                                setState(() {
                                  today = value;
                                });

                                selectedMonth = null;
                                period = false;
                              },
                            ),
                            const SizedBox(height: 10),
                            Text('Mes (${DateTime.now().year})'),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 5.0,
                              children: List<Widget>.generate(
                                DateTime.now().month,
                                (int index) {
                                  final month =
                                      DateTime(DateTime.now().year, index + 1);

                                  return ChoiceChip(
                                    label:
                                        Text(DateFormat.MMMM().format(month)),
                                    selected: month == selectedMonth,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        selectedMonth = selected ? month : null;
                                      });

                                      period = false;
                                      today = false;
                                    },
                                  );
                                },
                              ).toList(),
                            ),
                            const SizedBox(height: 10),
                            const Text('Otro Mes'),
                            const SizedBox(height: 5),
                            InputChip(
                              selected: selectedMonth != null && !thisYear,
                              label: Text(
                                selectedMonth == null || thisYear
                                    ? 'Seleccione'
                                    : DateFormat.yMMMM().format(selectedMonth!),
                              ),
                              onPressed: () async {
                                selectedMonth = await showMonthYearPicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                  initialDate: selectedMonth ?? DateTime.now(),
                                );

                                period = false;
                                today = false;

                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 10),
                            const Text('Periodo de tiempo'),
                            const SizedBox(height: 5),
                            ChoiceChip(
                              label: const Text('Seleccione'),
                              selected: period,
                              onSelected: (value) {
                                setState(() {
                                  period = value;
                                });

                                selectedMonth = null;
                                today = false;
                              },
                            ),
                            const SizedBox(height: 10),
                            if (period && selectedMonth == null)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: TimeFilterWidget(
                                  startDate: startDate,
                                  endDate: endDate,
                                  onChangeStart: (dateTime) {
                                    startDate = dateTime;
                                    setState(() {});
                                  },
                                  onChangeEnd: (dateTime) {
                                    endDate = dateTime;
                                    setState(() {});
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );

              this.today = today;
              this.selectedMonth = selectedMonth;
              this.startDate = !period ? null : startDate;
              this.endDate = !period ? null : endDate;

              widget.onChangeDateFilter?.call(
                today,
                selectedMonth,
                endDate,
                startDate,
              );

              setState(() {});
            },
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

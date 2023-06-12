import 'package:custom_data_table/src/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../custom_data_table.dart';
import '../filters/time_filter.dart';

typedef ChangeDateCallback = void Function(
    DateFilterType? dateFilterType, DateTime? date, DateTime? endDate);

class DatesFilterChip extends StatelessWidget {
  final DateFilterType? dateFilterType;
  final DateTime? date;
  final DateTime? endDate;
  final ChangeDateCallback? onChangeDateFilter;

  const DatesFilterChip({
    Key? key,
    this.dateFilterType,
    this.date,
    this.endDate,
    this.onChangeDateFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      elevation: 1,
      label: Text(
        'Escoger fechas',
        style: TextStyle(
          color: Theme.of(context).floatingActionButtonTheme.foregroundColor,
        ),
      ),
      avatar: Icon(
        Icons.calendar_month,
        color: Theme.of(context).floatingActionButtonTheme.foregroundColor,
      ),
      backgroundColor:
          Theme.of(context).floatingActionButtonTheme.backgroundColor,
      onPressed: () async {
        final _DateSelection? selection = await showModalBottomSheet(
          isDismissible: false,
          context: context,
          isScrollControlled: true,
          constraints: const BoxConstraints(
            maxWidth: 500,
            minWidth: 500,
          ),
          builder: (_) => DateFilterView(
            dateFilterType: dateFilterType,
            date: date,
            endDate: endDate,
          ),
        );

        onChangeDateFilter?.call(
          selection?.dateFilterType,
          selection?.date,
          selection?.endDate,
        );
      },
    );
  }
}

class DateFilterView extends StatefulWidget {
  final DateFilterType? dateFilterType;

  final DateTime? date;
  final DateTime? endDate;

  const DateFilterView({Key? key, this.dateFilterType, this.date, this.endDate})
      : super(key: key);

  @override
  State<DateFilterView> createState() => _DateFilterViewState();
}

class _DateFilterViewState extends State<DateFilterView> {
  static const startYear = 2020;

  DateFilterType? dateFilterType;

  DateTime? date;
  DateTime? endDate;

  @override
  void initState() {
    dateFilterType = widget.dateFilterType;

    date = widget.date;
    endDate = widget.endDate;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final thisYear = date?.year == DateTime.now().year;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20).copyWith(bottom: 5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Filtro de fechas',
                  style: Theme.of(context).textTheme.titleLarge,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                onPressed: () => Navigator.pop(
                  context,
                  _DateSelection(
                    dateFilterType: dateFilterType,
                    date: date,
                    endDate: endDate,
                  ),
                ),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        ),
        Flexible(
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20).copyWith(top: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Por día'),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      ChoiceChip(
                        label: const Text('Hoy'),
                        selected: dateFilterType == DateFilterType.date &&
                            date?.onlyDate == DateTime.now().onlyDate,
                        onSelected: (value) {
                          if (value) {
                            dateFilterType = DateFilterType.date;
                            date = DateTime.now().onlyDate;
                          } else {
                            dateFilterType = null;
                            date = null;
                            endDate = null;
                          }

                          setState(() {});
                        },
                      ),
                      ChoiceChip(
                        selected: dateFilterType == DateFilterType.date &&
                            date?.onlyDate != DateTime.now().onlyDate,
                        label: Text(dateFilterType != DateFilterType.date ||
                                date?.onlyDate == DateTime.now().onlyDate ||
                                date == null
                            ? 'Otro día'
                            : DateFormat('dd-MM-yyyy').format(date!)),
                        onSelected: (value) async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: date ?? DateTime.now(),
                            firstDate: DateTime(startYear),
                            lastDate: DateTime.now(),
                          );

                          if (selectedDate != null) {
                            dateFilterType = DateFilterType.date;
                            date = selectedDate;
                          } else {
                            dateFilterType = null;
                            date = null;
                            endDate = null;
                          }

                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Por Mes (${DateTime.now().year})'),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: List<Widget>.generate(
                      DateTime.now().month,
                      (int index) {
                        final month = DateTime(DateTime.now().year, index + 1);

                        return ChoiceChip(
                          label: Text(DateFormat.MMMM().format(month)),
                          selected: dateFilterType == DateFilterType.month &&
                              month == date?.onlyMonth,
                          onSelected: (bool selected) {
                            if (selected) {
                              dateFilterType = DateFilterType.month;
                              date = month.onlyMonth;
                            } else {
                              dateFilterType = null;
                              date = null;
                              endDate = null;
                            }

                            setState(() {});
                          },
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: 10),
                  const Text('Por Otro Mes'),
                  const SizedBox(height: 5),
                  InputChip(
                    selected:
                        dateFilterType == DateFilterType.month && !thisYear,
                    label: Text(
                      dateFilterType != DateFilterType.month ||
                              thisYear ||
                              date == null
                          ? 'Seleccione'
                          : DateFormat.yMMMM().format(date!),
                    ),
                    onPressed: () async {
                      final selectedMonth = await showMonthPicker(context: context);

                      if (selectedMonth != null) {
                        dateFilterType = DateFilterType.month;
                        date = selectedMonth.onlyMonth;
                      } else {
                        dateFilterType = null;
                        date = null;
                        endDate = null;
                      }

                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text('Por Año'),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: List<Widget>.generate(
                      DateTime.now().year - startYear + 1,
                      (int index) {
                        final year = DateTime(DateTime.now().year - index);

                        return ChoiceChip(
                          label: Text(DateFormat.y().format(year)),
                          selected: dateFilterType == DateFilterType.year &&
                              year == date?.onlyYear,
                          onSelected: (bool selected) {
                            if (selected) {
                              dateFilterType = DateFilterType.year;
                              date = year.onlyYear;
                            } else {
                              dateFilterType = null;
                              date = null;
                              endDate = null;
                            }

                            setState(() {});
                          },
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: 10),
                  const Text('Por Periodo de tiempo'),
                  const SizedBox(height: 5),
                  ChoiceChip(
                    label: const Text('Seleccione'),
                    selected: dateFilterType == DateFilterType.period,
                    onSelected: (value) {
                      if (value) {
                        dateFilterType = DateFilterType.period;

                        date = DateTime.now().onlyDate;
                        endDate = DateTime.now()
                            .onlyDate
                            .add(const Duration(days: 1));
                      } else {
                        dateFilterType = null;

                        date = null;
                        endDate = null;
                      }

                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: dateFilterType != DateFilterType.period
                        ? const SizedBox()
                        : TimeFilterWidget(
                            startDate: date ?? DateTime.now().onlyDate,
                            endDate: endDate ??
                                DateTime.now()
                                    .onlyDate
                                    .add(const Duration(days: 1)),
                            onChangeStart: (dateTime) {
                              date = dateTime;
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
            ),
          ),
        ),
      ],
    );
  }
}

class _DateSelection {
  DateFilterType? dateFilterType;

  DateTime? date;
  DateTime? endDate;

  _DateSelection({this.dateFilterType, this.date, this.endDate});
}

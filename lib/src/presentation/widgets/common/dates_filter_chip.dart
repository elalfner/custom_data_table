import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/core/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'package:custom_data_table/src/domain/enums/date_filter_type.dart';
import 'package:custom_data_table/src/core/utils/date_time_extension.dart';
import 'package:custom_data_table/src/presentation/widgets/common/custom_month_picker.dart';
import '../filters/time_filter.dart';

typedef ChangeDateCallback = void Function(DateSelection? dateFilter);

class DatesFilterChip extends StatelessWidget {
  final DateFilterType? dateFilterType;
  final DateTime? date;
  final DateTime? endDate;

  final DateTime? firstDate;
  final DateTime? lastDate;

  final ChangeDateCallback? onChangeDateFilter;

  final VoidCallback? onTapDateFilter;

  const DatesFilterChip({
    Key? key,
    this.dateFilterType,
    this.date,
    this.endDate,
    this.onChangeDateFilter,
    this.onTapDateFilter,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      elevation: 1,
      label: Text(
        context.appLocalizations.filterDates.naturalCapitalized,
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
        onTapDateFilter?.call();

        final customDateFilters = await showCustomDateFilters(
          context,
          initialDateFilter: DateSelection(
            dateFilterType: dateFilterType,
            date: date,
            endDate: endDate,
          ),
          firstDate: firstDate,
          lastDate: lastDate,
        );

        onChangeDateFilter?.call(customDateFilters);
      },
    );
  }
}

Future<DateSelection?> showCustomDateFilters(
  BuildContext context, {
  DateSelection? initialDateFilter,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DateFilterView(
      dateFilter: initialDateFilter,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _DateFilterView extends StatefulWidget {
  final DateSelection? dateFilter;

  final DateTime? firstDate;
  final DateTime? lastDate;

  const _DateFilterView(
      {Key? key, this.dateFilter, this.firstDate, this.lastDate})
      : super(key: key);

  @override
  State<_DateFilterView> createState() => _DateFilterViewState();
}

class _DateFilterViewState extends State<_DateFilterView> {
  static const startYear = 2020;

  DateSelection? dateFilter;

  bool get isWeek {
    final date = dateFilter?.date;
    if (date == null) return false;

    return date.startOfWeek == date && date.endOfWeek == dateFilter?.endDate;
  }

  @override
  void initState() {
    dateFilter = widget.dateFilter;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final date = dateFilter?.date;
    final endDate = dateFilter?.endDate;
    final dateFilterType = dateFilter?.dateFilterType;

    final thisYear = date?.year == DateTime.now().year;

    return PointerInterceptor(
      child: AlertDialog(
        scrollable: true,
        title: Row(
          children: [
            Expanded(
              child: Text(
                context.appLocalizations.filterDates.naturalCapitalized,
                style: Theme.of(context).textTheme.titleLarge,
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: Text(
                  context.appLocalizations.clearFilters.naturalCapitalized),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.appLocalizations.byDate.naturalCapitalized),
              const SizedBox(height: 5),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  ChoiceChip(
                    label:
                        Text(context.appLocalizations.today.naturalCapitalized),
                    selected: dateFilterType == DateFilterType.date &&
                        date?.onlyDate == DateTime.now().onlyDate,
                    onSelected: (value) {
                      if (value) {
                        final newDate = DateTime.now().onlyDate;

                        dateFilter = DateSelection(
                          dateFilterType: DateFilterType.date,
                          date: newDate,
                          endDate: newDate.endOfDay,
                        );
                      } else {
                        dateFilter = null;
                      }

                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    selected: dateFilterType == DateFilterType.date &&
                        date?.onlyDate != DateTime.now().onlyDate,
                    label: Text(
                      dateFilterType != DateFilterType.date ||
                              date?.onlyDate == DateTime.now().onlyDate ||
                              date == null
                          ? context
                              .appLocalizations.otherDate.naturalCapitalized
                          : DateFormat.yMd().format(date),
                    ),
                    onSelected: (value) async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: date ?? DateTime.now(),
                        firstDate: widget.firstDate ?? DateTime(startYear),
                        lastDate: widget.lastDate ?? DateTime.now(),
                        builder: (context, child) => Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            PointerInterceptor(child: child!),
                          ],
                        ),
                      );

                      if (selectedDate != null) {
                        dateFilter = DateSelection(
                          dateFilterType: DateFilterType.date,
                          date: selectedDate,
                          endDate: selectedDate.endOfDay,
                        );
                      } else {
                        dateFilter = null;
                      }

                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                  '${context.appLocalizations.byMonth.naturalCapitalized} (${DateTime.now().year})'),
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
                          dateFilter = DateSelection(
                            dateFilterType: DateFilterType.month,
                            date: month.onlyMonth,
                            endDate: month.endOfMonth,
                          );
                        } else {
                          dateFilter = null;
                        }

                        setState(() {});
                      },
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 10),
              Text(context.appLocalizations.byOtherMonth.naturalCapitalized),
              const SizedBox(height: 5),
              ChoiceChip(
                selected: dateFilterType == DateFilterType.month && !thisYear,
                label: Text(
                  dateFilterType != DateFilterType.month ||
                          thisYear ||
                          date == null
                      ? context.appLocalizations.select.naturalCapitalized
                      : DateFormat.yMMMM().format(date),
                ),
                onSelected: (bool selected) async {
                  final selectedMonth = await showMonthPicker(
                    context: context,
                    firstDate: widget.firstDate ?? DateTime(startYear),
                    lastDate: DateTime.now(),
                    initialDate: date ?? DateTime.now(),
                    builder: (context, child) => Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        PointerInterceptor(child: child!),
                      ],
                    ),
                  );

                  if (selectedMonth != null) {
                    dateFilter = DateSelection(
                      dateFilterType: DateFilterType.month,
                      date: selectedMonth.onlyMonth,
                      endDate: selectedMonth.endOfMonth,
                    );
                  } else {
                    dateFilter = null;
                  }

                  setState(() {});
                },
              ),
              const SizedBox(height: 10),
              Text(context.appLocalizations.byYear.naturalCapitalized),
              const SizedBox(height: 5),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: List<Widget>.generate(
                  DateTime.now().year -
                      (widget.firstDate ?? DateTime(startYear)).year +
                      1,
                  (int index) {
                    final year = DateTime(DateTime.now().year - index);

                    return ChoiceChip(
                      label: Text(DateFormat.y().format(year)),
                      selected: dateFilterType == DateFilterType.year &&
                          year == date?.onlyYear,
                      onSelected: (bool selected) {
                        if (selected) {
                          dateFilter = DateSelection(
                            dateFilterType: DateFilterType.year,
                            date: year.onlyYear,
                            endDate: year.endOfYear,
                          );
                        } else {
                          dateFilter = null;
                        }

                        setState(() {});
                      },
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 10),
              Text(context.appLocalizations.byPeriodOfTime.naturalCapitalized),
              const SizedBox(height: 5),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  ChoiceChip(
                    label: Text(
                        context.appLocalizations.select.naturalCapitalized),
                    selected:
                        dateFilterType == DateFilterType.period && !isWeek,
                    onSelected: (value) {
                      if (value) {
                        final newDate = DateTime.now().onlyDate;
                        dateFilter = DateSelection(
                          dateFilterType: DateFilterType.period,
                          date: newDate,
                          endDate: newDate.endOfDay,
                        );
                      } else {
                        dateFilter = null;
                      }

                      setState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: Text(
                        context.appLocalizations.thisWeek.naturalCapitalized),
                    selected: dateFilterType == DateFilterType.period && isWeek,
                    onSelected: (value) {
                      if (value) {
                        final newDate = DateTime.now().startOfWeek;

                        dateFilter = DateSelection(
                          dateFilterType: DateFilterType.period,
                          date: newDate,
                          endDate: newDate.endOfWeek,
                        );
                      } else {
                        dateFilter = null;
                      }

                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (!isWeek)
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
                            dateFilter = DateSelection(
                              dateFilterType: DateFilterType.period,
                              date: dateTime,
                              endDate: endDate,
                            );

                            setState(() {});
                          },
                          onChangeEnd: (dateTime) {
                            dateFilter = DateSelection(
                              dateFilterType: DateFilterType.period,
                              date: date,
                              endDate: dateTime,
                            );

                            setState(() {});
                          },
                        ),
                ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              dateFilter,
            ),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }
}

class DateSelection {
  DateFilterType? dateFilterType;

  DateTime? date;
  DateTime? endDate;

  DateSelection({this.dateFilterType, this.date, this.endDate});

  String? label(BuildContext context) {
    if (dateFilterType == DateFilterType.date &&
        date?.onlyDate == DateTime.now().onlyDate) {
      return context.appLocalizations.onlyToday;
    }

    if (dateFilterType == DateFilterType.date &&
        date != null &&
        date?.onlyDate != DateTime.now().onlyDate) {
      return DateFormat.yMd().format(date!);
    }

    if (dateFilterType == DateFilterType.month && date != null) {
      return DateFormat.yMMMM().format(date!);
    }

    if (dateFilterType == DateFilterType.year && date != null) {
      return DateFormat.y().format(date!);
    }

    if (dateFilterType == DateFilterType.period &&
        date != null &&
        endDate != null) {
      return '${DateFormat.yMd().add_Hm().format(date!)} - ${DateFormat.yMd().add_Hm().format(endDate!)}';
    }

    return null;
  }

  bool get isWeek {
    final date = this.date;
    if (date == null) return false;

    return date.startOfWeek == date && date.endOfWeek == endDate;
  }
}

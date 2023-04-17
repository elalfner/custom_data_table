import 'package:custom_data_table/src/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../filters/time_filter.dart';

typedef ChangeDateCallback = void Function(
    bool today, DateTime? month, DateTime? startDate, DateTime? endDate);

class DatesFilterChip extends StatelessWidget {
  final bool today;
  final DateTime? selectedMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final ChangeDateCallback? onChangeDateFilter;

  const DatesFilterChip({
    Key? key,
    required this.today,
    this.selectedMonth,
    this.startDate,
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
                final thisYear = selectedMonth?.year == DateTime.now().year;

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
                              label: Text(DateFormat.MMMM().format(month)),
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

        onChangeDateFilter?.call(
          today,
          selectedMonth,
          !period ? null : startDate,
          !period ? null : endDate,
        );
      },
    );
  }
}

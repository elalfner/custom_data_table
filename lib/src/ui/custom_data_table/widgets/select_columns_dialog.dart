import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/domain/models/column_info.dart';
import 'package:custom_data_table/src/utils/string_extension.dart';
import 'package:flutter/material.dart';

/// Dialog to select columns to show.
class SelectColumnsToShowDialog extends StatefulWidget {
  /// List of columns to show.
  final List<ColumnInfo> columns;

  /// List of selected columns.
  final List<ColumnInfo> selectedColumns;

  const SelectColumnsToShowDialog(
      {super.key, required this.columns, required this.selectedColumns});

  @override
  State<SelectColumnsToShowDialog> createState() =>
      _SelectColumnsToShowDialogState();
}

class _SelectColumnsToShowDialogState extends State<SelectColumnsToShowDialog> {
  /// List of selected columns.
  late List<ColumnInfo> selectedColumns;

  @override
  void initState() {
    // Initializes the selected columns.
    selectedColumns = [...widget.selectedColumns];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // List of columns to show.
    final columns = widget.columns;

    return AlertDialog(
      title: Text(
        context.appLocalizations.columnsToShow.naturalCapitalized,
      ),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final col in columns)
            if (col.name.isNotEmpty)
              CheckboxListTile(
                value: selectedColumns.any((element) => element.key == col.key),
                onChanged: (value) {
                  selectedColumns
                      .removeWhere((element) => element.key == col.key);

                  if (value == true) {
                    selectedColumns.add(col);
                  }

                  setState(() {});
                },
                title: Text(col.name),
              ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () {
            // Returns the selected columns.
            final selectedColumns = widget.columns.where(
              (element) {
                return this.selectedColumns.any(
                      (e) => element.key == e.key,
                    );
              },
            ).toList();

            Navigator.of(context).pop(selectedColumns);
          },
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

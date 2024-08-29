import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';

class Example2 extends StatelessWidget {
  const Example2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
        child: CustomDataTable<Map<String, dynamic>>(
          columns: [
            ColumnInfo(key: 'from', name: 'From', width: 100),
            ColumnInfo(key: 'to', name: 'To', flex: 1, width: 200),
            ColumnInfo(
              key: 'too',
              name: 'Too',
              width: 300,
              canSearchInput: true,
            ),
          ],
          data: [
            {'from': 'Hola', 'to': 'Hola', 'too': 'Too'},
            {'from': 'Hola', 'to': 'Hola', 'too': 'Too'},
            {'from': 'Hola', 'to': 'Hola', 'too': 'Too'},
            {'from': 'Hola', 'to': 'Hola', 'too': 'Too'},
            {'from': 'Hola', 'to': 'Hola', 'too': 'Too'},
            {'from': 'Hola', 'to': 'Hola', 'too': 'Too'},
            {'from': 'Hola', 'to': 'Hola', 'too': 'Too'},
            {'from': 'Hola', 'to': 'Hola', 'too': 'Too'},
          ],
          toMap: (element) => element,
          paginatorInfo: PaginatorInfo(
            perPage: 10,
            total: 100,
            currentPage: 1,
            lastPage: 10,
          ),
          onChangeSearchTextField: (values) {},
        ),
      ),
    );
  }
}

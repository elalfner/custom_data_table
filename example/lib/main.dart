import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';

import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xFF31394D).withOpacity(0.09),
          filled: true,
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1.5,
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1.5,
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1.5,
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1.5,
              color: Colors.pink,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1.5,
              color: Colors.pink,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<User> data = [
    User(id: 1, name: 'Hugo', phone: '3347294736', userType: UserType.admin),
    User(id: 2, name: 'Paco', phone: '3392053734', userType: UserType.admin),
    User(id: 5, name: 'Luis', phone: '3392053734', userType: UserType.user),
  ];

  List<FilterItem>? filtersUserType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomTableSearch<User>(
          data: data,
          title: 'Usuarios',
          columns: [
            ColumnInfo(name: 'Id', key: 'id', flex: 1, width: 100),
            ColumnInfo(name: 'Nombre', key: 'name', flex: 2, width: 300),
            ColumnInfo(name: 'Teléfono', key: 'phone', width: 110),
            ColumnInfo(name: 'Email', key: 'email', width: 110),
            ColumnInfo(name: 'Tipo', key: 'userType', width: 100),
            ColumnInfo(name: '', key: 'button', flex: 1, width: 100),
          ],
          toMap: (element) => element.toJsonTable(),
          paginatorInfo: PaginatorInfo(
            total: 100,
            perPage: 20,
            currentPage: 2,
            lastPage: 5,
          ),
          onChangeSearchFields: (values) {},
          onChangeSearchTextField: (values) {
            print({
              for (final v in values) v.columnInfo.name: v.searchValue,
            });
          },
          cell: (element, map, key) {
            switch (key) {
              case 'button':
                return IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => print(element.id),
                  icon: const Icon(Icons.block),
                  color: Colors.pink,
                  splashRadius: 20,
                );
            }

            return null;
          },
          onSort: (sortInfo) {
            switch (sortInfo.columnInfo.key) {
              case 'id':
                if (sortInfo.asc) {
                  data.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
                } else {
                  data.sort((b, a) => (a.id ?? 0).compareTo(b.id ?? 0));
                }
                break;
              case 'name':
                if (sortInfo.asc) {
                  data.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
                } else {
                  data.sort((b, a) => (a.name ?? '').compareTo(b.name ?? ''));
                }
                break;
              case 'userType':
                if (sortInfo.asc) {
                  data.sort((a, b) => (a.userType?.name ?? '')
                      .compareTo(b.userType?.name ?? ''));
                } else {
                  data.sort((b, a) => (a.userType?.name ?? '')
                      .compareTo(b.userType?.name ?? ''));
                }
            }
          },
          onElementPressed: (value) {},
        ),
      ),
    );
  }
}

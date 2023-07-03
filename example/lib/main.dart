import 'dart:io';

import 'package:custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final String defaultLocale = Platform.localeName;
  Intl.defaultLocale = defaultLocale;
  await initializeDateFormatting(defaultLocale, null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
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
      dividerColor: const Color(0xffe7e7e7),
    );
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
      ],
      debugShowCheckedModeBanner: false,

      // themeMode: ThemeMode.dark,
      theme: theme.copyWith(
        dataTableTheme: DataTableThemeData(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff000000).withOpacity(0.16),
                blurRadius: 9.0,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          dividerThickness: 0.7,
          dataRowColor: MaterialStateProperty.resolveWith(
            (states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.grey[200];
              }
              return null;
            },
          ),
          headingRowColor: MaterialStateProperty.resolveWith(
            (states) {
              if (states.contains(MaterialState.selected)) {
                return theme.colorScheme.secondaryContainer;
              }
              return null;
            },
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xff585858),
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
    User(id: 5, name: 'Luis', phone: '3392053734', userType: UserType.user),
    User(id: 5, name: 'Luis', phone: '3392053734', userType: UserType.user),
    User(id: 5, name: 'Luis', phone: '3392053734', userType: UserType.user),
    User(id: 5, name: 'Luis', phone: '3392053734', userType: UserType.user),
  ];

  List<FilterItem>? filtersUserType;

  PaginatorInfo paginatorInfo =
      PaginatorInfo(lastPage: 10, currentPage: 5, perPage: 8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomFilters(
              sections: [
                FilterSection<TipoVehiculo>(
                    columnInfo: ColumnId(key: 'type', name: 'Tipo de vehículo'),
                    filters: [
                      FilterItem(
                        filterName: 'Particular',
                        value: TipoVehiculo(name: 'particular'),
                      ),
                      FilterItem(
                        filterName: 'Motocicleta',
                        value: TipoVehiculo(name: 'moto'),
                      ),
                    ],
                    selectedFilters: [
                      FilterItem(
                        filterName: 'Motocicleta',
                        value: TipoVehiculo(name: 'moto'),
                      ),
                    ]),
                FilterSection<Clase>(
                  columnInfo: ColumnId(key: 'clase', name: 'Clase'),
                  filters: [
                    FilterItem(
                      filterName: 'Particular',
                      value: Clase(name: 'particular'),
                    ),
                    FilterItem(
                      filterName: 'Público',
                      value: Clase(name: 'publico'),
                    ),
                  ],
                ),
              ],
              onChange: (sections) {
                print(sections);
              },
              onChangeDateFilter: (dateFilterType, date, endDate) {},
            ),
            const SizedBox(height: 20),
            Expanded(
              child: CustomTableSearch<User>(
                data: data,
                title: 'Usuarios',
                columns: [
                  ColumnInfo(
                    name: 'Id',
                    key: 'id',
                    canSearch: true,
                    flex: 1,
                    width: 100,
                    canSearchInput: true,
                  ),
                  ColumnInfo(name: 'Nombre', key: 'name', flex: 2, width: 300),
                  ColumnInfo(
                    name: 'Teléfono',
                    key: 'phone',
                    width: 110,
                    canSearchInput: true,
                    controllerInput: TextEditingController(text: 'Prueba'),
                    onChangeInput: (value) {
                      print(value);
                    },
                  ),
                  ColumnInfo(
                    name: 'Email',
                    key: 'email',
                    width: 110,
                    canSearch: true,
                    canSort: false,
                  ),
                  ColumnInfo(name: 'Tipo', key: 'userType', width: 100),
                  ColumnInfo(name: '', key: 'button', flex: 1, width: 100),
                ],
                toMap: (element) => element.toJsonTable(),
                onChangeSearchFilter: (values) {
                  print(values);
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
                paginatorInfo: paginatorInfo,
                onPreviousPage: () {
                  paginatorInfo = paginatorInfo.copyWith(
                      currentPage: (paginatorInfo.currentPage ?? 0) - 1);
                  setState(() {});
                },
                onNextPage: () {
                  paginatorInfo = paginatorInfo.copyWith(
                      currentPage: (paginatorInfo.currentPage ?? 0) + 1);
                  setState(() {});
                },
                onSelectedPage: (page) {
                  paginatorInfo = paginatorInfo.copyWith(currentPage: page);
                  setState(() {});
                },
                generalSearchDecoration: const InputDecoration(
                  hintText: 'Buscar',
                ),
                onChangeGeneralSearch: (value) {
                  print(value);
                },
                onChangeSearchTextField: (values) {},
                onPerPageChange: (perPage) {
                  print(perPage);
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
                        data.sort(
                            (a, b) => (a.name ?? '').compareTo(b.name ?? ''));
                      } else {
                        data.sort(
                            (b, a) => (a.name ?? '').compareTo(b.name ?? ''));
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
                onPrint: () {},
                onElementPressed: (value) {},
                filterSections: [
                  FilterSection(
                    columnInfo: ColumnId(key: 'hola', name: 'hola'),
                    filters: [
                      FilterItem(filterName: 'Hola', value: 'Hola'),
                      FilterItem(filterName: 'Como', value: 'Como'),
                    ],
                    selectedFilters: [
                      FilterItem(filterName: 'Como', value: 'Como'),
                    ],
                  ),
                ],
                onChangeFilters: (values) {},
                onChangeDateFilter: (dateFilterType, date, endDate) {
                  print(dateFilterType);
                  print(date);
                  print(endDate);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Clase {
  final String? id;
  final String? name;

  Clase({this.id, this.name});
}

class TipoVehiculo {
  final String? id;
  final String? name;

  TipoVehiculo({this.id, this.name});
}

## 1. Domain Entities & Helper Constructors

- [x] 1.1 Add `PaginatorInfo.singlePage({required int total})` factory constructor in `lib/src/domain/entities/paginator_info.dart`
- [x] 1.2 Add Dart docstrings for `PaginatorInfo.singlePage` adhering to documentation guidelines
- [x] 1.3 Add unit tests for `PaginatorInfo.singlePage` in `test/custom_data_table_test.dart`

## 2. Presentation State Decoupling

- [x] 2.1 Decouple `error` calculation in `lib/src/presentation/widgets/custom_data_table.dart` to check `data == null && !widget.isLoading`
- [x] 2.2 Update content `Builder` in `lib/src/presentation/widgets/custom_data_table.dart` to only evaluate `if (data == null)`
- [x] 2.3 Update docstrings for `paginatorInfo` in `CustomDataTable` documenting unpaginated / single-page behavior

## 3. Automated Test Coverage

- [x] 3.1 Add widget test verifying table rendering with `paginatorInfo: null` renders rows and columns without `TableFooter`
- [x] 3.2 Add widget test verifying table rendering with valid `paginatorInfo` renders `TableFooter`
- [x] 3.3 Add widget test verifying `loadingBuilder` renders when `data == null && isLoading == true`
- [x] 3.4 Add widget test verifying `exceptionBuilder` renders when `data == null && isLoading == false`

## 4. Documentation & Verification

- [x] 4.1 Update `README.md` with GraphQL Lighthouse integration instructions, `Fragment$PaginatorExtension` snippet, and single-page table example
- [x] 4.2 Verify code formatting, static analysis, and automated test execution across the project

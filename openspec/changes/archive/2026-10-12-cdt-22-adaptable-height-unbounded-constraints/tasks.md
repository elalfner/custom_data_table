## 1. Content Height Calculation Refactoring

- [x] 1.1 Remove `final contentHeight = ValueNotifier<double?>(null);` from `_CustomDataTableState` in `lib/src/presentation/widgets/custom_data_table.dart`
- [x] 1.2 Remove synchronous mutation of `contentHeight.value` inside `build()`
- [x] 1.3 Implement pure helper `calculateContentHeight({required int itemCount, required double minRowHeight, required double dividerHeight})`
- [x] 1.4 Remove `ValueListenableBuilder` wrapper from the table body

## 2. Adaptable Constraint Handling

- [x] 2.1 Extract table content building logic inside `_body()` into a structured child container
- [x] 2.2 Evaluate `constraints.hasBoundedHeight` in `LayoutBuilder`
- [x] 2.3 Render table content inside `Flexible` when `constraints.hasBoundedHeight == true` (preserving bounded scroll behavior)
- [x] 2.4 Render table content inside `SizedBox(height: contentHeight + 10)` when `constraints.hasBoundedHeight == false` (handling unbounded viewports)
- [x] 2.5 Ensure loading and exception states gracefully adapt under both bounded and unbounded constraints

## 3. Automated Test Coverage

- [x] 3.1 Add unit tests for `calculateContentHeight` covering empty and populated data lists
- [x] 3.2 Add widget test verifying `CustomDataTable` renders properly inside bounded height (`Expanded` / `SizedBox`) with functional vertical scrolling
- [x] 3.3 Add widget test verifying `CustomDataTable` renders properly inside unbounded vertical viewport (`SingleChildScrollView`) without `RenderFlex` exceptions
- [x] 3.4 Verify existing tests in `test/custom_data_table_test.dart` continue to pass without regression

## 4. Quality Standards & Pre-Flight Verification

- [x] 4.1 Run `dart format --output=none --set-exit-if-changed .` to verify formatting
- [x] 4.2 Run `flutter analyze --fatal-infos` to ensure zero errors, zero warnings, and zero infos
- [x] 4.3 Run `flutter test` to ensure 100% test pass rate
- [x] 4.4 Run `flutter pub publish --dry-run` to ensure package integrity

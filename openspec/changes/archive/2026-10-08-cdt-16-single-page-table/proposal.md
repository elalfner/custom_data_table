## Why

Currently, `CustomDataTable` contains a state evaluation flaw: if `paginatorInfo` is `null`, it presumes the table is in a loading or error state, rendering a blank `SizedBox` when `isLoading` is `false`. This prevents developers from using the table for non-paginated datasets (such as locally filtered lists, small collections, or static server endpoints). Furthermore, developers need a streamlined way to construct single-page pagination metadata and standard patterns for integrating with GraphQL Lighthouse APIs (e.g. `graphql_codegen`).

## What Changes

- Decouple data presence (`data == null`) from pagination metadata (`paginatorInfo == null`) in `CustomDataTable` state handling.
- Allow `CustomDataTable` to render data rows, columns, and search filters normally when `paginatorInfo` is `null`, while omitting the pagination footer (`TableFooter`).
- Add a convenience factory constructor `PaginatorInfo.singlePage({required int total})` in `PaginatorInfo`.
- Update API documentation and docstrings across `CustomDataTable` and `PaginatorInfo` following Dart documentation guidelines.
- Add comprehensive widget and unit tests covering non-paginated table rendering, pagination footer presence/absence, loading states, and error states.
- Document GraphQL Lighthouse integration and single-page usage patterns in `README.md`.

## Capabilities

### New Capabilities
- `single-page-table`: Renders tabular data without pagination controls when `paginatorInfo` is `null`, maintaining full search and column functionality while omitting `TableFooter`.
- `paginator-helpers-and-graphql`: Convenience constructors (`PaginatorInfo.singlePage`) and GraphQL Lighthouse schema mapping patterns for clean client-side integration.

### Modified Capabilities
<!-- None: existing specs in openspec/specs/ are continuous-integration, package-readiness, and table-localization. -->

## Impact

- `lib/src/presentation/widgets/custom_data_table.dart`: State condition logic and docstrings updated.
- `lib/src/domain/entities/paginator_info.dart`: `PaginatorInfo.singlePage` constructor and docstrings added.
- `test/custom_data_table_test.dart`: Unit and widget tests added to verify unpaginated behavior and state builders.
- `README.md`: Documentation extended with single-page and GraphQL integration examples.
- Zero breaking changes to existing public APIs; fully backward-compatible with existing clients such as `viali_panel`.

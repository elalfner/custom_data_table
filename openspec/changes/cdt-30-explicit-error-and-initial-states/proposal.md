## Why

In reactive architectures (MVVM, BLoC, Riverpod, Command Pattern), `CustomDataTable` currently exhibits false-positive error states. In `TableContent`, it blindly evaluates `(data == null && !isLoading)` as a network failure, triggering `exceptionBuilder` ("Connection error") during initial idle states before any search or query is executed.

Furthermore, `CustomDataTable` lacks explicit error properties (`hasError` and `error`), cannot display an idle/initial screen before the first query is submitted (`initialBuilder`), exposes an outdated builder naming convention (`exceptionBuilder` instead of Flutter's canonical `errorBuilder`), does not pass the error instance or `BuildContext` to error callbacks, and provides no visual feedback when background refetches or pagination queries fail while stale data is still on screen.

## What Changes

- **Explicit Error Control**: Add optional `final bool? hasError;` and `final Object? error;` parameters to `CustomDataTable` and `TableContent`.
  - When `hasError` is specified (`hasError != null`), it acts as the single source of truth for error evaluation.
  - When `hasError` is omitted (`hasError == null`), a legacy fallback (`data == null && !isLoading`) is retained for 100% backwards compatibility.
- **Initial / Idle State Support**: Add an optional `final Widget Function()? initialBuilder;` parameter rendered when `data == null && !isLoading && hasError == false`.
- **Modern Idiomatic Error Builder**: Introduce `final Widget Function(BuildContext context, Object? error)? errorBuilder;` providing direct access to the `BuildContext` and error payload.
- **Soft Deprecation of Legacy Builder**: Deprecate `exceptionBuilder` with `@Deprecated('Use errorBuilder instead. Will be removed in future versions.')` while maintaining full runtime fallback support.
- **Background Refetch Error Banner**: Add `final bool showErrorBanner;` (default `false`) and `final Widget Function(BuildContext context, Object? error)? errorBannerBuilder;` allowing users to display an informative warning banner above existing data rows when a refetch fails (`data != null && hasError == true`) without destroying visible table content.

## Capabilities

### New Capabilities
- `table-error-and-initial-states`: Explicit error state control (`hasError`, `error`), canonical `errorBuilder` with context/error injection, background refetch error banners (`showErrorBanner`, `errorBannerBuilder`), and dedicated initial/idle state representation (`initialBuilder`).

### Modified Capabilities
- `single-page-table`: Refine the decoupled error state scenario so that `data == null && !isLoading` does not trigger error displays when `hasError == false`, resolving false-positive exceptions during initial idle states.

## Impact

- `lib/src/ui/custom_data_table/widgets/custom_data_table.dart`: Expose `hasError`, `error`, `initialBuilder`, `errorBuilder`, `showErrorBanner`, `errorBannerBuilder`, and deprecate `exceptionBuilder`. Forward new properties to `TableContent`.
- `lib/src/ui/custom_data_table/widgets/table_content.dart`: Refactor state resolution to deterministically handle initial idle, loading, error, empty, and data states; support background error banners; prioritize `errorBuilder` over `exceptionBuilder`.
- `test/ui/custom_data_table/`: Add comprehensive widget and unit tests for idle states, explicit error flags, errorBuilder arguments, backwards compatibility fallback, and background error banners.

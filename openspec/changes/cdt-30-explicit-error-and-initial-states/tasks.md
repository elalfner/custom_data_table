## 1. Public API and Parameter Delegation

- [x] 1.1 Add `hasError`, `error`, `initialBuilder`, `errorBuilder`, `showErrorBanner`, and `errorBannerBuilder` to `CustomDataTable`
- [x] 1.2 Add `@Deprecated` annotation to `exceptionBuilder` in `CustomDataTable`
- [x] 1.3 Forward new properties and builders from `CustomDataTable` to `TableContent`
- [x] 1.4 Add `hasError`, `error`, `initialBuilder`, `errorBuilder`, `showErrorBanner`, and `errorBannerBuilder` to `TableContent` with deprecated `exceptionBuilder`

## 2. State Resolution Engine in TableContent

- [x] 2.1 Implement tri-state error computation `_computeHasError` supporting explicit `hasError` with legacy fallback
- [x] 2.2 Implement hierarchical error state builder `_buildErrorState` prioritizing `errorBuilder` over `exceptionBuilder`
- [x] 2.3 Add initial/idle state rendering branch returning `initialBuilder?.call() ?? const SizedBox()` when `data == null && !isLoading && !isError`
- [x] 2.4 Add background error banner rendering when `data != null && isError && showErrorBanner` using `errorBannerBuilder` or default banner

## 3. Automated Verification and Tests

- [x] 3.1 Add widget test for initial idle state (`data == null`, `isLoading == false`, `hasError == false`) rendering `initialBuilder` without error triggers
- [x] 3.2 Add widget test for legacy backwards compatibility fallback when `hasError` is omitted (`null`)
- [x] 3.3 Add widget test for `errorBuilder` receiving `BuildContext` and `Object? error` payload
- [x] 3.4 Add widget test for legacy `exceptionBuilder` fallback when `errorBuilder` is null
- [x] 3.5 Add widget tests for background refetch error banner when `data != null` with `showErrorBanner: true` vs `false`
- [x] 3.6 Validate codebase formatting (`dart format`), static analysis (`flutter analyze --fatal-infos`), and test suite (`flutter test`)

## Context

In reactive Flutter applications (BLoC, Riverpod, MVVM, Command Pattern), UI state typically begins in an initial/idle state where no data has been fetched yet (`data == null`, `isLoading == false`, `hasError == false`). Currently, `TableContent` evaluates `(data == null && !isLoading)` blindly as an error, invoking `exceptionBuilder` ("Connection error") before the user has performed any search or filter action.

Additionally, `CustomDataTable` lacks explicit error properties, uses the legacy name `exceptionBuilder` rather than Flutter's standard `errorBuilder`, does not forward the caught error object to the builder, and provides no built-in visual notification when a background refresh fails while existing records remain on screen.

## Goals / Non-Goals

**Goals:**
- Provide explicit error control (`hasError` and `error`) with a zero-breaking-change fallback for legacy consumers.
- Support an idle/initial state builder (`initialBuilder`) when `data == null && !isLoading && hasError == false`.
- Introduce canonical Flutter `errorBuilder(BuildContext context, Object? error)` and deprecate `exceptionBuilder`.
- Provide an optional, configurable error banner (`showErrorBanner` and `errorBannerBuilder`) for background refresh errors when `data != null`.
- Guarantee clean height handling and 100% test coverage across all state transitions.

**Non-Goals:**
- Breaking existing constructor signatures: `loadingBuilder` and `emptyBuilder` remain `Widget Function()?` to preserve developer ergonomics and backwards compatibility.
- Introducing external state management dependencies into `custom_data_table`.

## Decisions

### Decision 1: Tri-state Error Evaluation
Instead of forcing boolean `hasError`, we define `final bool? hasError;` and `final Object? error;`.
- When `hasError == true`: The table is unequivocally in an error state.
- When `hasError == false`: The table is unequivocally NOT in an error state, even if `data == null`.
- When `hasError == null`: Fallback to legacy behavior `(data == null && !isLoading)` so existing screens without `hasError` continue to operate without regressions.

### Decision 2: Canonical Error Builder and Graceful Deprecation
We introduce:
```dart
final Widget Function(BuildContext context, Object? error)? errorBuilder;

@Deprecated('Use errorBuilder instead. Will be removed in future versions.')
final Widget Function()? exceptionBuilder;
```
When rendering an error state:
1. If `errorBuilder != null`, call `errorBuilder!(context, widget.error)`.
2. Else if `exceptionBuilder != null`, call `exceptionBuilder!()`.
3. Otherwise, render default fallback error widget or `const SizedBox()`.

### Decision 3: Deterministic State Rendering Pipeline
In `TableContent.build`, states are resolved in strict sequential priority:
1. **Initial Load**: `data == null && isLoading == true` $\rightarrow$ `loadingBuilder` or centered `CircularProgressIndicator` (100.0 px compact height).
2. **Initial Error**: `data == null && isError` $\rightarrow$ `_buildErrorState(context, widget.error)`.
3. **Initial Idle**: `data == null && !isLoading && !isError` $\rightarrow$ `initialBuilder?.call() ?? const SizedBox()`.
4. **Empty Dataset**: `data != null && data.isEmpty` $\rightarrow$ `emptyBuilder` or localized placeholder (100.0 px compact height).
5. **Populated Dataset**: `data != null && data.isNotEmpty` $\rightarrow$ Render rows.
   - If `isLoading == true`: Top `LinearProgressIndicator` active.
   - If `isError == true && showErrorBanner == true`: Render `errorBannerBuilder?.call(context, widget.error)` or default error banner above rows without clearing data.

### Decision 4: Background Error Banner Slot
When `data != null && hasError == true`, destroying the visible rows is jarring. Consumers can set `showErrorBanner: true` (default `false`) to display a warning bar above the table content. If `showErrorBanner` is `false`, `CustomDataTable` maintains existing rows silently, allowing the screen to handle errors via custom snackbars or banners if preferred.

## Risks / Trade-offs

- **[Risk]** Existing apps expecting `data == null && !isLoading` to show an error might be surprised if they explicitly set `hasError: false`.
  $\rightarrow$ **Mitigation:** Explicit `hasError: false` is an active opt-in declaring "there is no error". Omitted `hasError` retains legacy behavior.
- **[Risk]** Unbounded layout overflow if `initialBuilder` returns an unconstrained widget.
  $\rightarrow$ **Mitigation:** Wrap `initialBuilder` inside safe box constraints or document bounded requirements similar to empty state.

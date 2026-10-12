## Context

`CustomDataTable` (`lib/src/presentation/widgets/custom_data_table.dart`) is a comprehensive Flutter table widget supporting search filters, sorting, row selection, horizontal scrolling for overflow columns, and pagination.

Inside its `_body()` method, the table structure is built as a `Column` containing:
1. Header row / column search fields wrapped in horizontal scroll views.
2. Table content wrapped inside a `Flexible` widget and a `ValueListenableBuilder` listening to `final contentHeight = ValueNotifier<double?>(null);`.
3. Footer controls (`TableFooter`).

During the `build()` method, `contentHeight.value` is mutated synchronously:
```dart
if (data != null) {
  contentHeight.value = data.isEmpty
      ? 0
      : (rowMinHeight * data.length +
          ((dividerHeight ?? 0) * (data.length - 1)));
}
```

This implementation causes two key architectural problems:
1. **Unbounded Height Exception**: When `CustomDataTable` is placed inside any vertically scrollable container (`SingleChildScrollView`, `ListView`, `CustomScrollView`), the incoming vertical constraints are unbounded (`maxHeight: double.infinity`). Flutter's `Column` rejects `Flexible` children under unbounded height, immediately throwing:
   ```
   RenderFlex children have non-zero flex but incoming height constraints are unbounded.
   ```
2. **Lifecycle Side-Effects**: Mutating a `ValueNotifier` synchronously within `build()` triggers reactive listener notifications while the framework is in the middle of a build pass, conflicting with Flutter widget lifecycle invariants.

## Goals / Non-Goals

**Goals:**
- Eliminate `ValueNotifier<double?> contentHeight` and all state mutations inside `build()`.
- Compute table content height using a pure, synchronous helper function.
- Evaluate `constraints.hasBoundedHeight` inside `_body()` to branch layout handling:
  - Under bounded constraints (`hasBoundedHeight == true`): Wrap table content in `Flexible` to preserve existing flex layout and enable vertical scrolling when content exceeds available height.
  - Under unbounded constraints (`hasBoundedHeight == false`): Wrap table content in a `SizedBox(height: contentHeight + 10)` to render at natural dimensions without crashing flex layout.
- Maintain 100% backward compatibility with bounded usages (such as `Expanded` wrappers in `viali_panel`).
- Provide robust automated widget tests covering bounded and unbounded height environments.

**Non-Goals:**
- Modifying horizontal scroll physics, sticky headers, or column rendering mechanisms.
- Changing pagination models, footer mechanics, or theming APIs.
- Introducing external dependencies for layout detection.

## Decisions

### 1. Pure Synchronous Content Height Calculation
- **Choice**: Implement a standalone helper method/function:
  ```dart
  double calculateContentHeight({
    required int itemCount,
    required double minRowHeight,
    required double dividerHeight,
  }) {
    if (itemCount == 0) return 0.0;
    return (minRowHeight * itemCount) + (dividerHeight * (itemCount - 1));
  }
  ```
- **Rationale**: Removes `ValueNotifier` overhead, eliminates `ValueListenableBuilder` indirection, and restores purity to the `build()` method.
- **Alternatives Considered**:
  - *Post-frame callback (`addPostFrameCallback`)*: Causes a 1-frame layout delay and visible flicker.
  - *GlobalKey with RenderBox layout measurements*: Overly complex and requires two layout passes.

### 2. Constraint-Based Layout Branching (`constraints.hasBoundedHeight`)
- **Choice**: In `_body()`, leverage the existing `LayoutBuilder`'s `BoxConstraints`:
  - When `constraints.hasBoundedHeight` is `true`:
    Wrap the table content container in `Flexible(child: tableContentContainer)`.
  - When `constraints.hasBoundedHeight` is `false`:
    Wrap the table content container in `SizedBox(height: contentHeight + 10, child: tableContentContainer)`.
- **Rationale**: `hasBoundedHeight` is the canonical Flutter framework API to detect whether an incoming height constraint is finite or infinite. By conditionally substituting `Flexible` with `SizedBox`, the table effortlessly adapts to both `Expanded` containers and scrollable viewports.
- **Alternatives Considered**:
  - *Add a boolean property `shrinkWrap` or `isUnbounded` to `CustomDataTable`*: Rejected because callers should not have to manually toggle flags when the incoming `BoxConstraints` already know whether the height is bounded.
  - *Always use `SizedBox` without `Flexible`*: Rejected because it breaks setups where the table is placed inside an `Expanded` and expected to fill available vertical space with internal scroll bars.

### 3. Graceful Handling for Null Data / Loading States
- **Choice**: When `data == null` (loading or error state):
  - Under bounded height: `Flexible` wraps the loading/exception widget.
  - Under unbounded height: `SizedBox` wraps the widget with a reasonable fallback or allows the widget to size itself appropriately.
- **Rationale**: Guarantees zero crashes during initial data fetch or network failure when placed in a scroll view.

## Risks / Trade-offs

- **[Risk] Unbounded container with extensive rows**: If an unpaginated dataset with hundreds of rows is rendered inside an unbounded `SingleChildScrollView`, all rows will be laid out in one pass.
  - *Mitigation*: `CustomDataTable` is designed primarily for paginated datasets (typically 10-50 items per page). For large datasets, pagination controls ensure low row counts per page.
- **[Risk] Sizing discrepancy with row margins or custom decorators**: The `+ 10` buffer accommodates bottom scrollbar padding and borders.
  - *Mitigation*: The buffer mirrors the existing `maxHeight: contentHeight + 10` constraint calculation, preserving exact visual fidelity and padding.

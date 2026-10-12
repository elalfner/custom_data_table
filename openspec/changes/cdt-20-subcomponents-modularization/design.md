## Context

Following the foundational folder reorganization in CDT-18, `CustomDataTable` is situated within `lib/src/ui/custom_data_table/widgets/custom_data_table.dart`. However, the internal implementation still contains over 1,200 lines within `_CustomDataTableState`, constructing all visual subcomponents through private helper methods (`header()`, `tableContent()`, `rowWidget()`, `columnsWidget()`, `columnWidget()`, `columnFieldWidget()`, `cell()`).

The official **Flutter Architecture Case Study** ([docs.flutter.dev/app-architecture/case-study](https://docs.flutter.dev/app-architecture/case-study)) and core Flutter performance guidelines establish that UI layers should be built from compositions of focused, dedicated widget classes rather than helper methods returning widgets. Helper methods trigger complete widget tree rebuilds on transient state mutations (e.g. search keystrokes, column filter changes, row hover), prevent `const` subtree caching, and make isolated widget testing impossible.

This design decouples `_CustomDataTableState` into specialized, atomic sub-widgets under `lib/src/ui/custom_data_table/widgets/` while maintaining 100% backward compatibility with the existing public API.

---

## Goals / Non-Goals

**Goals:**
- **Atomic Sub-widget Extraction**: Decompose internal rendering methods into 5 specialized widget classes:
  1. `TableHeader`: Top actions toolbar (columns selector, quick actions, filter triggers, debounced general search).
  2. `TableColumnsHeader`: Container row for column header titles with synchronized horizontal scrolling.
  3. `TableColumnHeader`: Individual column header cell (sort toggle and optional column search input).
  4. `TableContent`: Viewport with dual scrollbars (horizontal/vertical) and adaptive height handling.
  5. `TableRowWidget`: Individual data row rendering with zebra striping, hover feedback, and cell builder delegation.
- **Lean Orchestration**: Reduce `custom_data_table.dart` to ~180 lines, serving solely as a declarative orchestrator.
- **Preserve CDT-22 Layout Adaptability**: Encapsulate finite (`hasBoundedHeight`) vs infinite constraint adaptation and `calculateContentHeight` without regressions.
- **Preserve Linked Scroll Synchronization**: Retain exact horizontal scroll synchronization between column headers and content via `LinkedScrollControllerGroup`.
- **Comprehensive Widget Testing**: Mirror `lib/src/ui/custom_data_table/widgets/` in `test/ui/custom_data_table/widgets/` with dedicated widget test suites for each subcomponent.

**Non-Goals:**
- Transforming `TableController` into a full MVVM ViewModel (out of scope; would break the 25+ parameter public API contract used by consumers such as `viali_panel`).
- Modifying public API signatures, parameters, or export contracts in `lib/custom_data_table.dart`.
- Modifying existing visual themes, styles, colors, or animations.

---

## Decisions

### 1. Separation of Column Headers: Row Container (`TableColumnsHeader`) vs Cell (`TableColumnHeader`)
- **Decision**: Introduce both `TableColumnsHeader` (representing the full horizontal row with scroll and column spacing) and `TableColumnHeader` (representing the individual column cell with title, sort toggle, and text search input).
- **Rationale**: If only an individual cell widget were created, `columnsWidget()` would remain as an orphaned helper method inside `_CustomDataTableState`. Separating the container row from the cell item enforces complete separation of concerns.
- **Alternatives Considered**: Inlining the row layout inside `TableContent`. Rejected because column headers are structurally distinct from data rows and possess independent scroll/padding geometry.

### 2. Prevention of Flutter SDK Name Collisions (`TableRowWidget`)
- **Decision**: Name the row component `TableRowWidget` rather than `TableRow`.
- **Rationale**: Flutter's core SDK already defines `TableRow` in `package:flutter/src/widgets/table.dart`. As emphasized in Flutter's architecture documentation, choosing non-colliding names prevents symbol confusion and ambiguous imports.
- **Alternatives Considered**: `CustomDataTableRow`. `TableRowWidget` was chosen for consistency with the Jira ticket specification and CDT naming conventions.

### 3. Scroll Synchronization via Controller Injection
- **Decision**: The orchestrator (`_CustomDataTableState`) manages the `LinkedScrollControllerGroup` and injects:
  - `_columnsHeaderController` into `TableColumnsHeader`.
  - `_hContentScrollController` and `_verticalScrollController` into `TableContent`.
- **Rationale**: Sub-widgets remain pure presentation components that receive their scroll dependencies via constructor parameters. This makes each sub-widget independently testable in isolation without depending on linked controllers.

### 4. Encapsulation of Adaptive Height Handling (CDT-22 Preservation)
- **Decision**: `TableContent` directly accepts `BoxConstraints constraints` and encapsulates the container sizing logic (`calculateContentHeight`, `hasBoundedHeight` handling with `Flexible`, and infinite constraints sizing).
- **Rationale**: Keeps layout constraint decisions cohesive within the content viewport while ensuring zero regression for the unbounded height capabilities introduced in CDT-22.

### 5. Unidirectional Data Flow (UDF) & Dialog Encapsulation in `TableHeader`
- **Decision**: `TableHeader` directly invokes existing dialogs (`SelectColumnsToShowDialog`, `SelectFiltersDialog`, `DateFilterDialog`) from `context`, then communicates resulting user selections upstream via typed callbacks (`onSelectedColumnsChanged`, `onChangeFilters`, `onChangeDateFilter`).
- **Rationale**: Conforms to the MVVM presentation layer standard where views capture user interactions and surface clean event callbacks to the coordinator.

---

## Component Architecture & Data Flow

```
┌────────────────────────────────────────────────────────────────────────┐
│ CustomDataTable<T> / _CustomDataTableState<T> (Orchestrator)           │
└────────────────────────────────────────────────────────────────────────┘
       │                              │                      │
       ▼                              ▼                      ▼
┌─────────────────────────┐  ┌─────────────────────┐  ┌──────────────────┐
│ TableHeader             │  │ TableColumnsHeader  │  │ TableContent     │
│ - Columns dialog        │  │ - Horizontal scroll │  │ - Dual scrollbar │
│ - Filter & date dialogs │  │ - Linked controller │  │ - Adaptive height│
│ - Search & action tools │  │   ┌───────────────┐ │  │   ┌────────────┐ │
│                         │  │   │TableColumn-   │ │  │   │TableRow-   │ │
│                         │  │   │Header (cells) │ │  │   │Widget      │ │
│                         │  │   └───────────────┘ │  │   └────────────┘ │
└─────────────────────────┘  └─────────────────────┘  └──────────────────┘
       ▲                              ▲                      ▲
       │ Callbacks                    │ Callbacks            │ Callbacks
       └──────────────────────────────┴──────────────────────┘
```

---

## Risks / Trade-offs

- **[Risk] Broken horizontal scroll synchronization between header and content**
  → *Mitigation*: Ensure both controllers originate from the same `LinkedScrollControllerGroup` in `_CustomDataTableState` and verify synchronized scrolling in widget tests.
- **[Risk] Regression in unbounded height layouts (CDT-22)**
  → *Mitigation*: Run existing bounded and unbounded review tests (`flutter test`) and verify that `calculateContentHeight` produces identical height measurements.
- **[Risk] Unnecessary rebuilds during text input**
  → *Mitigation*: Isolate `TextEditingController` listeners and `Debouncer` executions within `TableHeader` and `TableColumnHeader`, avoiding triggering global `setState` in `CustomDataTable`.

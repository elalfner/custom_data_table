---
name: Bug Report
about: Report a reproducible bug or layout issue in CustomDataTable
title: '[BUG] '
labels: bug
assignees: ''
---

<!--
  Thank you for taking the time to report this issue and help us improve CustomDataTable!
  Before creating a report, please check if a similar issue already exists.
-->

## 1. Describe the Bug
A clear and concise description of the bug or unexpected behavior.

## 2. Parent Widget & Layout Context 📐
*DataTables are highly sensitive to parent constraints (e.g., unbounded height or missing expanded widgets).*

- **Direct Parent Widget:** [e.g. `Scaffold -> Expanded`, `SizedBox(width: 800, height: 600)`, `Column without Expanded`]
- **Execution Mode:** [ ] Debug  [ ] Profile  [ ] Release
- **If Web:** [ ] WASM (`--wasm`)  [ ] CanvasKit  [ ] HTML  [ ] Not running on Web

## 3. Minimal Reproducible Example 💻
Please provide a minimal, self-contained `main.dart` sample that reproduces the issue when run with `flutter run`:

```dart
import 'package:flutter/material.dart';
import 'package:custom_data_table/custom_data_table.dart';

void main() => runApp(const MaterialApp(home: BugReproPage()));

class BugReproPage extends StatelessWidget {
  const BugReproPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomDataTable(
        // Paste minimal configuration reproducing the bug here
      ),
    );
  }
}
```

## 4. Steps to Reproduce & Expected Behavior
1. Run the app on `...`
2. Perform action `...`
3. See error or visual glitch

- **Expected:** Description of what you expected to happen.
- **Actual:** Description of what actually happened.

## 5. Visual Evidence 📸
*(Drag & drop screenshots or screen recordings showing the issue, if applicable)*

## 6. Full Error Stack Trace 🛑
<details>
<summary>Click to view exception and console logs</summary>

```
Paste full console output / stack trace here
```
</details>

## 7. `flutter doctor -v` 🩺
<details>
<summary>Click to view flutter doctor output</summary>

```
Paste output of `flutter doctor -v` here
```
</details>

---

*Thank you for taking the time to report this issue and help make CustomDataTable better!*

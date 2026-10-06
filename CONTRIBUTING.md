# Contributing to CustomDataTable

Thank you for your interest in contributing to **CustomDataTable**! We welcome bug reports, feature suggestions, documentation improvements, and pull requests.

---

## Code of Conduct

Please help us maintain a friendly, welcoming, and inclusive community. Be respectful and constructive in all discussions, issues, and pull requests.

---

## Branching Strategy (Git Flow)

We follow a Git Flow branching model:

- **`main`**: Production-ready code matching the latest stable release.
- **`dev`**: **Default branch**. All feature branches and bug fixes must be branched from and targeted to `dev`.

### Branch Naming
- **Community Contributors:** Name your branch after the feature or the GitHub Issue:
  - `feature/<short-description>` or `feature/<issue-number>-<short-description>` (e.g., `feature/custom-empty-view`, `feature/5-empty-state`)
  - `fix/<short-description>` or `fix/<issue-number>-<short-description>` (e.g., `fix/8-padding-overflow`)
- **Core Team (Jira):** `feature/CDT-<ticket>-<desc>` or `fix/CDT-<ticket>-<desc>` (e.g., `feature/CDT-12-custom-cell-align`).

---

## Getting Started

1. **Fork the Repository:** Create your own fork of `elalfner/custom_data_table` on GitHub.
2. **Clone your fork:**
   ```bash
   git clone https://github.com/<your-username>/custom_data_table.git
   cd custom_data_table
   ```
3. **Checkout `dev` and create your branch:**
   ```bash
   git checkout dev
   git checkout -b feature/your-feature-name
   # or with an issue number: git checkout -b feature/5-your-feature-name
   ```
4. **Install dependencies:**
   ```bash
   flutter pub get
   ```

---

## Quality Standards & Local Verification

Before submitting a pull request, make sure your code passes all CI checks:

1. **Format Code:**
   ```bash
   dart format --output=none --set-exit-if-changed .
   ```
   *(To auto-format files, run `dart format .`)*

2. **Static Analysis:** Ensure there are zero warnings or informational lints:
   ```bash
   flutter analyze --fatal-infos
   ```

3. **Run Tests:** All existing and new tests must pass:
   ```bash
   flutter test
   ```

4. **Package Dry-Run:** Verify pub.dev package integrity:
   ```bash
   flutter pub publish --dry-run
   ```

5. **Example App:** If you introduced UI or API changes, update and verify `example/`:
   ```bash
   cd example
   flutter pub get
   flutter analyze --no-fatal-infos --no-fatal-warnings
   ```

---

## Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): [<OPTIONAL_TICKET_OR_ISSUE>] <short description in imperative mood>
```

- **For Community Contributors:**
  - If resolving a GitHub Issue, reference the issue number:
    `feat(table): [#5] add empty state placeholder` *(GitHub will automatically link the issue)*
  - If not tied to an existing issue, the ticket reference is omitted:
    `feat(theme): add dark mode alternate row colors`
    `fix(filters): resolve date picker range overflow on small screens`
- **For Core Team (Jira):**
  - Use your internal Jira ticket ID:
    `feat(theme): [CDT-14] add support for custom column borders`
    `fix(scroll): [CDT-18] sync horizontal headers on trackpad swipe`

---

## Submitting a Pull Request

1. Push your branch to your GitHub fork:
   ```bash
   git push -u origin feature/your-feature-name
   ```
2. Open a Pull Request targeting the **`dev`** branch (never `main` directly).
3. Fill out the PR description with:
   - What changes were made and why.
   - Any related issue numbers (e.g., `Closes #12`).
   - Screenshots or video recordings if you changed UI behavior.
4. Ensure all automated GitHub Actions checks pass in green (`✓`).
5. A maintainer will review your pull request and collaborate with you on any needed revisions.

---

Thank you for helping make `custom_data_table` better for the Flutter community!

# Agent Guidelines & Workspace Rules

This document establishes the permanent operational rules and conventions for all AI coding agents working on the `custom_data_table` repository.

---

## 1. Language Policy (Strict Invariant)

### Chat Conversation vs. Project Deliverables
- **Chat Language**: The user may converse in Spanish (or any other language) in the chat interface. The agent must respond to the user in their preferred conversation language (e.g., Spanish).
- **Project Deliverables**: **ALL generated and edited project files, code, and artifacts MUST be strictly written in English.**

### Zero-Tolerance Scope
The English-only rule applies unconditionally to:
1. **Source Code**:
   - Class names, functions, methods, variables, constants, enums, parameters, and typedefs.
2. **Code Comments & Docstrings**:
   - Inline comments (`//`), block comments (`/* ... */`), and Dart docstrings (`///`).
3. **Version Control**:
   - Git commit messages (e.g., `feat(table): ...`, `fix(scroll): ...`).
   - Branch names (e.g., `feature/...`, `fix/...`, `chore/...`).
   - Pull request titles, descriptions, and change summaries.
4. **Documentation**:
   - `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, issue templates, licenses.
5. **OpenSpec Artifacts**:
   - All proposals (`proposal.md`), design documents (`design.md`), task breakdowns (`tasks.md`), and capability specifications (`specs/**/*.md`).
6. **Automated Tests**:
   - Test descriptions (`test('renders empty state when items is empty', ...)`), group titles, and test fixture comments.
7. **Library Output & Messages**:
   - Default UI labels, error messages, assertions, and console logs produced by `CustomDataTable`.

### Rule Precedence
Even if the user's prompt or task instructions in the chat contain Spanish terms (e.g., *"agrega un botón para ordenar"*), the resulting code, commits, and comments must always be written in English (e.g., *"add sort button"*).

---

## 2. Git Flow & Branching Strategy

- **`main`**: Production-ready branch matching the latest stable release published on pub.dev.
- **`dev`**: **Default integration branch**. All feature branches and bug fixes must branch from and target `dev`.
- **Branch Naming**:
  - Community: `feature/<issue>-<short-name>` or `fix/<issue>-<short-name>`.
  - Core Team (Jira): `feature/CDT-<ticket>-<short-name>` or `fix/CDT-<ticket>-<short-name>`.

---

## 3. Commit Message Standards (Conventional Commits)

Format:
```
<type>(<scope>): [<TICKET_OR_ISSUE>] <short imperative description in English>
```

- **Types**: `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `chore`, `ci`.
- **Tickets / Issues**:
  - Core Team: `[CDT-xxx]` (e.g., `feat(columns): [CDT-12] add sticky column support`).
  - Community: `[#xxx]` (e.g., `fix(padding): [#8] resolve row overflow on small screens`) or omit ticket if no issue exists.

---

## 4. Quality Standards & Pre-Flight Verification

Before concluding any implementation task or opening a PR, ensure all verification commands pass:

1. **Format Check**:
   ```bash
   dart format --output=none --set-exit-if-changed .
   ```
2. **Static Analysis**: Zero errors, zero warnings, zero infos:
   ```bash
   flutter analyze --fatal-infos
   ```
3. **Automated Tests**:
   ```bash
   flutter test
   ```
4. **Pub.dev Dry-Run**:
   ```bash
   flutter pub publish --dry-run
   ```

### Publishing Constraint
- **NEVER** run `flutter pub publish` without the `--dry-run` flag unless the user explicitly gives direct approval in the conversation.

---

## 5. Clean Repository History & Privacy

- Never introduce references to internal migration history or Bitbucket in recent commits, OpenSpec documents, or code.
- Keep package payload lightweight: verify that `.pubignore` excludes `.agent/`, `openspec/`, and development build folders.

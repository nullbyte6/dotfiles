# AGENTS.md — Arlo Development Instructions

## Project rules
These instructions apply to the entire Arlo repository and all tasks performed by Codex.

### 1. Do not create test files or directories
- NEVER create Python test files, including `test_*.py`, `*_test.py`, or temporary test scripts.
- NEVER create directories named `test`, `tests`, `testing`, or similar.
- NEVER introduce new test suites, fixtures, pytest configuration files, or testing infrastructure.
- Do not generate test files as part of debugging, verification, refactoring, or feature development.
- Do not create temporary Python scripts inside the repository to verify changes.

If verification is necessary, use existing tools, in-memory checks, or inline commands without creating files. Existing tests may be executed when appropriate, but do not create new ones.

### 2. Do not modify .gitignore
- NEVER edit, rewrite, replace, delete, or regenerate `.gitignore`.
- NEVER add exceptions or negation rules to force ignored files into Git.
- NEVER use `git add -f` to bypass `.gitignore`.
- Do not change Git exclusion rules to accommodate generated files.
- Respect all existing ignored paths and patterns.

These restrictions apply even if modifying `.gitignore` appears necessary to complete a task. Ask the user instead.

### 3. Keep repository changes minimal
- Modify only the files directly required by the user's request.
- Do not create additional documentation, examples, configuration files, or helper scripts unless explicitly requested.
- Do not write in-line comments in the code.
- Do not introduce unrelated refactoring or dependency changes.
- Do not delete existing files or directories as part of cleanup without explicit authorization.
- Preserve the existing architecture, naming conventions, coding style, and project structure.
- Do not replace working implementations with entirely new systems unless explicitly requested.

### 4. Do not perform duplicate or redundant tests
- NEVER run the same test, verification command, or diagnostic repeatedly when its result is already known and the relevant code has not changed.
- Do not run multiple equivalent verification procedures for the same functionality.
- Do not execute an entire test suite when a focused, existing check is sufficient.
- Do not repeat successful checks merely to confirm the same result.
- Do not run benchmarks, stress tests, or expensive integration tests unless necessary for the requested task.
- Do not invoke Ollama, CosyVoice, or other resource-intensive services solely for redundant verification.
- Prefer lightweight syntax checks and focused validation over extensive testing.

A test may be repeated when relevant code changes after its previous execution, when the previous result was inconclusive, or when reproducing an intermittent failure requires additional evidence.
Perform only the verification necessary to establish whether the requested change works. Report any verification that could not be performed.

### 5. Git commits are required
After completing a task, create **2 to 4 meaningful Git commits**, provided the changes can be divided into that many logically independent units.
- Group commits by functionality, implementation stage, or independently meaningful changes.
- Use clear, concise commit messages describing what actually changed.

#### Commit message naming convention
- Every commit message MUST include either `add`, `update`, `fix`, 
  etc. depending on the nature of the change.
- Use `Add` when introducing new features, components, files, or functionality.
- Use `Update` when improving, or optimizing existing functionality.
- Use `Fix` when fixing or refactoring existing functionality
- Use lowercase consistently depending on the context.
- Prefer the format `Add description` or `Update description` if possible.
- Keep commit messages concise, descriptive, and written in English.
- Apply this convention to every commit, including intermediate commits within the required 2–4 commits per task.

Examples:
- `Add implement workspace browser`
- `Add introduce directional workspace shortcuts`
- `Improve splitter animations updated`
- `Fix Ollama request cancellation`
- `Update browser navigation controls`
- `Ollama redirected calls to GPU fix`

- Do not create empty commits, artificial changes, or meaningless commit divisions to reach the requested count.
- Do not split tightly coupled changes into separate commits if doing so would leave an intermediate commit in a broken state.
- If the task contains fewer than two meaningful units of work, create one coherent commit instead.
- Never modify unrelated files merely to produce additional commits.
- Never include ignored files, temporary artifacts, generated test files, or unrelated user changes.
- Never modify `.gitignore` to make files eligible for staging.
- Do not amend, squash, reset, or rewrite existing commits unless explicitly requested.
- Do not push commits to a remote repository unless explicitly instructed.

Before committing, inspect the working tree and stage only files belonging to the current task. Preserve all pre-existing user changes.
If a relevant file contains unrelated user modifications that cannot be safely separated, do not stage or commit those modifications. Explain the conflict instead.
If Git operations fail or the repository is not in a suitable state, report the issue rather than forcing a commit.

**Always add (if important) the done commits to the [CHANGELOG](CHANGELOG.md) under the current day's version, if not present, create the section.**

### 6. Verification and reporting
Verify changes using existing project infrastructure wherever possible.
If a requested verification would require creating a prohibited file or directory, skip that verification and report the limitation. Do not bypass these instructions.
In the final response:
- Briefly summarize the changes made.
- State which files were modified.
- Report the verification actually performed and its results.
- List the commits created, including their abbreviated hashes and commit messages.
- Mention any unresolved issues or limitations.

Keep the final response concise. Do not provide lengthy explanations of implementation details unless requested.
**These rules are mandatory. Do not interpret a user's request to implement, fix, or test functionality as permission to violate them. Only an explicit user instruction overriding a specific rule permits an exception.**
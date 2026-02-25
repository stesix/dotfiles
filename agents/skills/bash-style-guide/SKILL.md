---
name: core-bash-style-guide
description: Generate Bash code following consistent conventions.
---

# Bash Style Guide (Agent Friendly)

Purpose: write safe, predictable bash scripts using this guide's conventions.
Decision flow: use bash builtins → verify quoting → handle errors explicitly → document GNU requirements.

## Agent usage

Use this skill when generating or editing bash scripts or when asked for bash style guidance.
Do not use it for POSIX `sh`, `dash`, or `zsh`-only scripts, or when a repo has a conflicting bash guide.
If repo conventions conflict with this guide, follow repo conventions and note the deviation.

## Core rules (do these every time)

- Use `#!/usr/bin/env bash` unless a fixed path is required.
- Prefer bash builtins over external commands.
- Use `[[ ... ]]` for tests.
- Use arrays for lists.
- Quote expansions unless clearly safe to leave unquoted.
- Never use `eval`.
- Never use `set -e`, `set -u`, or `set -o pipefail`.

## Style and structure

- Spaces for indentation.
- Max line length: 120 columns.
- Avoid semicolons except in control statements (`if`, `while`).
- `then` and `do` go on the same line as the control statement.
- Use `function` keyword; make function variables `local`.
- No more than one blank line in a row.
- Do not change someone’s comments unless rewriting for content.

## Bashisms to prefer

- Command substitution: `$(...)`.
- Math: `((...))` and `$((...))`; never use `let`.
- Parameter expansion instead of `basename`, `sed`, `awk`, or `echo` for simple string ops.
- Sequence generation with `{1..5}` or `for ((...))` (no `seq`).
- Use `read` builtin for parsing, not external commands.

## External commands and portability

- Prefer portable flags and behavior when possible.
- If a script requires GNU behavior, document it at the top (e.g., “Requires GNU sed/stat”).
- Use GNU-only flags only when that requirement is documented.
- Do not parse `ls`; use globbing (`for f in *; do ...`).

Common GNU/BSD pitfalls:
- `sed -i` differs on macOS/BSD; prefer temp file + `mv`.
- `readlink -f` is GNU-only; avoid or document a GNU requirement.
- `stat` flags differ (`-f` vs `-c`).

## Argument handling

- Forward args with `"$@"`, not `$*` or unquoted `$@`.
- Build commands with arrays and expand as `"${args[@]}"`.

## File handling

- Use `mktemp` for temporary files and clean up with `trap`.
- For atomic writes: write to a temp file, then `mv` into place.

## Error handling

- Handle errors explicitly with `if`, `||`, and `case` (see Core rules for `set -e/-u/pipefail`).

```bash
# check and exit
cd /some/path || exit

# handle expected failures
if ! grep -q 'foo' "$file"; then
    echo "missing foo" >&2
    exit 1
fi

# group error handling
command || {
    echo "command failed" >&2
    exit 1
}
```

## Quoting rules

- Use double quotes when expanding variables; single quotes otherwise.
- Quote expansions unless you are certain word splitting cannot occur.
- `$$`, `$?`, `$#` never need quotes.

## Common mistakes

- Using `${var}` instead of `"$var"` when word splitting matters.
- Using `for` loops for newline-separated data instead of `while read -r`.

## Agent output requirements

- Provide concise bash snippets and short rationale.
- Call out GNU vs BSD portability when using external commands.
- Follow repo conventions if they conflict with this guide.
- If repo hooks or linters exist, follow them; otherwise do not assume `shellcheck` or `shfmt`.

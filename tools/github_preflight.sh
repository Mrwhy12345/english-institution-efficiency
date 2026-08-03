#!/usr/bin/env bash
set -euo pipefail

for command_name in git gh rg; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $command_name" >&2
    exit 1
  fi
done

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

branch_name="$(git branch --show-current)"
remote_url="$(git remote get-url origin)"

echo "Repository: $repo_root"
echo "Branch:     $branch_name"
echo "Remote:     $remote_url"

if [[ -z "$branch_name" ]]; then
  echo "ERROR: detached HEAD is not allowed for publishing." >&2
  exit 1
fi

if [[ "$branch_name" == "main" || "$branch_name" == "master" ]]; then
  echo "ERROR: create a codex/<topic> branch before publishing." >&2
  exit 1
fi

echo
echo "[1/5] GitHub authentication"
gh auth status

echo
echo "[2/5] Working tree"
git status -sb

echo
echo "[3/5] Diff formatting"
git diff --check
git diff --cached --check

echo
echo "[4/5] Tracked temporary or credential files"
forbidden_files="$(git ls-files | rg '(^|/)(tmp|__pycache__)(/|$)|\.pyc$|\.cnf$|create_cyana_accounts\.sql$' || true)"
if [[ -n "$forbidden_files" ]]; then
  echo "$forbidden_files" >&2
  echo "ERROR: forbidden temporary or credential files are tracked." >&2
  exit 1
fi

echo
echo "[5/5] Common secret patterns"
secret_matches="$(git grep -nE 'gh[opusr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY' -- ':!tools/github_preflight.sh' || true)"
if [[ -n "$secret_matches" ]]; then
  echo "$secret_matches" >&2
  echo "ERROR: possible secret detected in tracked files." >&2
  exit 1
fi

echo
echo "PASS: GitHub publish preflight completed."
echo "Next: review scope, stage explicit files, validate staged diff, commit, push, and verify the draft PR."

#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <read|write> <client.cnf> <script.sql>" >&2
  exit 2
fi

mode="$1"
client_config="$2"
sql_script="$3"
mysql_bin="${MYSQL_BIN:-/usr/local/mysql/bin/mysql}"

case "$mode" in
  read) expected_user="cyana_reader" ;;
  write) expected_user="cyana_writer" ;;
  *)
    echo "ERROR: mode must be read or write." >&2
    exit 2
    ;;
esac

if [[ ! -x "$mysql_bin" ]]; then
  echo "ERROR: MySQL client not executable: $mysql_bin" >&2
  exit 1
fi

if [[ ! -f "$client_config" ]]; then
  echo "ERROR: client config not found: $client_config" >&2
  exit 1
fi

if [[ ! -f "$sql_script" ]]; then
  echo "ERROR: SQL script not found: $sql_script" >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
script_dir="$(cd "$(dirname "$sql_script")" && pwd)"
script_path="$script_dir/$(basename "$sql_script")"
script_hash="$(shasum -a 256 "$script_path" | awk '{print $1}')"
current_user="$($mysql_bin --defaults-extra-file="$client_config" --batch --skip-column-names --execute='SELECT CURRENT_USER();')"

if [[ "$current_user" != "$expected_user"@* ]]; then
  echo "ERROR: mode '$mode' requires $expected_user, connected as $current_user." >&2
  exit 1
fi

timestamp="$(date '+%Y%m%d_%H%M%S')"
operation_id="OP_${timestamp}_$RANDOM"
log_dir="$repo_root/.local/mysql-operation-logs"
log_file="$log_dir/${operation_id}_${mode}.log"
mkdir -p "$log_dir"
chmod 700 "$repo_root/.local" "$log_dir"

{
  echo "operation_id=$operation_id"
  echo "started_at=$(date '+%Y-%m-%d %H:%M:%S %z')"
  echo "mode=$mode"
  echo "mysql_user=$current_user"
  echo "script_path=$script_path"
  echo "script_sha256=$script_hash"
  echo "git_commit=$(git -C "$repo_root" rev-parse HEAD)"
  echo "--- mysql output ---"
} > "$log_file"
chmod 600 "$log_file"

set +e
"$mysql_bin" \
  --defaults-extra-file="$client_config" \
  --show-warnings \
  --verbose \
  < "$script_path" \
  2>&1 | tee -a "$log_file"
mysql_status="${PIPESTATUS[0]}"
set -e

{
  echo "--- execution result ---"
  echo "completed_at=$(date '+%Y-%m-%d %H:%M:%S %z')"
  echo "exit_status=$mysql_status"
} >> "$log_file"

if [[ "$mysql_status" -ne 0 ]]; then
  echo "FAILED: MySQL exited with status $mysql_status" >&2
  echo "Trace: $log_file" >&2
  exit "$mysql_status"
fi

echo "PASS: script executed successfully."
echo "Trace: $log_file"

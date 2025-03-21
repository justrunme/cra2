#!/bin/bash
set -e

echo "🔁 Running all tests..."

cd "$(dirname "$0")"

export CREATE_REPO_BIN="$(cd "$(dirname "$0")/.."; pwd)/create-repo"

for test in test_*.sh; do
  echo "▶️  Running $test"
  bash "$test"
done

echo "✅ All tests passed."

#!/bin/bash
set -e

echo "🔁 Running all tests..."

cd "$(dirname "$0")"

for test in test_*.sh; do
  echo "▶️  $test"
  bash "$test"
done

echo "✅ All tests passed."

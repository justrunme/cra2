#!/bin/bash
set -e

echo "🔁 Running all tests..."

# Перейти в папку test
cd "$(dirname "$0")"

# Пройтись по всем test_*.sh
for test in test_*.sh; do
  echo "▶️  Running $test"
  bash "$test"
done

echo "✅ All tests passed."

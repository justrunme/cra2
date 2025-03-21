#!/bin/bash
echo "🧪 Testing invalid flags..."
! create-repo --invalid-flag 2>&1 | grep -q "Unknown flag" || {
  echo "❌ Invalid flag not detected"
  exit 1
}
echo "✅ Flag validation test passed"

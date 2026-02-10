#!/bin/bash

echo "========================================"
echo "  Automated Paging Test Script"
echo "========================================"
echo ""

# UE IP addresses (from subscriber_db.csv)
UE1_IP="10.45.1.2"
UE2_IP="10.45.1.3"
UE3_IP="10.45.1.4"

echo "This script will:"
echo "1. Generate traffic to make UE active"
echo "2. Wait for UE to go idle (20+ seconds)"
echo "3. Trigger paging by sending ping"
echo ""
read -p "Press Enter to start test with UE1..."

echo ""
echo "=== Testing UE1 (IP: $UE1_IP) ==="
echo "Step 1: Generating traffic..."
ping $UE1_IP -c 3 -i 1

echo ""
echo "Step 2: Waiting 25 seconds for UE to go IDLE..."
echo "(Watch the monitor terminal for [IDLE] message)"
sleep 25

echo ""
echo "Step 3: Triggering paging..."
echo "(Watch the monitor terminal for [PAGE] and [CONN] messages)"
ping $UE1_IP -c 1

echo ""
echo "✓ UE1 paging test complete!"
echo ""
read -p "Press Enter to test UE2..."

echo ""
echo "=== Testing UE2 (IP: $UE2_IP) ==="
echo "Step 1: Generating traffic..."
ping $UE2_IP -c 3 -i 1

echo "Step 2: Waiting 25 seconds for UE to go IDLE..."
sleep 25

echo "Step 3: Triggering paging..."
ping $UE2_IP -c 1

echo ""
echo "✓ UE2 paging test complete!"
echo ""
read -p "Press Enter to test UE3..."

echo ""
echo "=== Testing UE3 (IP: $UE3_IP) ==="
echo "Step 1: Generating traffic..."
ping $UE3_IP -c 3 -i 1

echo "Step 2: Waiting 25 seconds for UE to go IDLE..."
sleep 25

echo "Step 3: Triggering paging..."
ping $UE3_IP -c 1

echo ""
echo "========================================"
echo "✓ All paging tests complete!"
echo "========================================"
```


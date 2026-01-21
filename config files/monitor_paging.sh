#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Real-Time RRC & Paging Monitor${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}Monitoring: /tmp/gnb.log${NC}"
echo ""
echo -e "${BLUE}Legend:${NC}"
echo -e "${GREEN}[ACTV]${NC} - UE in RRC_CONNECTED (active)"
echo -e "${BLUE}[IDLE]${NC} - UE released to RRC_IDLE"
echo -e "${RED}[PAGE]${NC} - Paging message sent (core paging UE)"
echo -e "${YELLOW}[CONN]${NC} - UE requesting connection"
echo ""
echo "Waiting for gNB to start..."
echo ""

# Wait for log file to exist
while [ ! -f /tmp/gnb.log ]; do
    sleep 1
done

tail -f /tmp/gnb.log | while read line; do
    if echo "$line" | grep -qi "RRCRelease"; then
        echo -e "${BLUE}[$(date '+%H:%M:%S')] [IDLE]${NC} UE released to RRC_IDLE state"
    elif echo "$line" | grep -qi "Paging"; then
        echo -e "${RED}[$(date '+%H:%M:%S')] [PAGE]${NC} ⚠️  PAGING MESSAGE SENT ⚠️"
    elif echo "$line" | grep -qi "RRCSetupRequest"; then
        echo -e "${YELLOW}[$(date '+%H:%M:%S')] [CONN]${NC} UE requesting connection"
    elif echo "$line" | grep -qi "RRCSetupComplete"; then
        echo -e "${GREEN}[$(date '+%H:%M:%S')] [ACTV]${NC} UE now in RRC_CONNECTED"
    elif echo "$line" | grep -qi "PDU Session Establishment"; then
        echo -e "${PURPLE}[$(date '+%H:%M:%S')] [DATA]${NC} PDU Session established"
    fi
done
```
**Save and make executable:**
```bash
chmod +x monitor_paging.sh
```

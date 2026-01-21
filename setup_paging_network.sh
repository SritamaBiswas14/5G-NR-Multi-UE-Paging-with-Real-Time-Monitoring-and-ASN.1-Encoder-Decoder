#!/bin/bash

echo "====================================="
echo "  srsRAN 3-UE Paging Network Setup  "
echo "====================================="

# Create network namespaces
echo "Creating network namespaces..."
sudo ip netns add ue1 2>/dev/null
sudo ip netns add ue2 2>/dev/null
sudo ip netns add ue3 2>/dev/null

# Verify namespaces
echo "Network namespaces created:"
ip netns list

echo ""
echo "Setup complete! Ready to start network components."
echo ""
echo "==== START SEQUENCE ===="
echo "Terminal 1: cd ~/srsRAN_Project/docker && docker compose up 5gc"
echo "Terminal 2: cd ~/srsRAN_Project/utils/gnuradio && gnuradio-companion multi_ue_scenario.grc"
echo "Terminal 3: cd ~/srsRAN_Project/build/apps/gnb && sudo ./gnb -c /root/srsRAN_config/gnb_zmq.yaml"
echo "Terminal 4: cd ~/srsRAN_4G/build/srsue/src && sudo ./srsue /root/srsRAN_config/ue1_zmq.conf"
echo "Terminal 5: cd ~/srsRAN_4G/build/srsue/src && sudo ./srsue /root/srsRAN_config/ue2_zmq.conf"
echo "Terminal 6: cd ~/srsRAN_4G/build/srsue/src && sudo ./srsue /root/srsRAN_config/ue3_zmq.conf"
echo "Terminal 7: cd /root && ./monitor_paging.sh"
```
**Save and make executable:**
```bash
chmod +x setup_paging_network.sh
```

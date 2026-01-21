# 📗 README.md

# **5G NR Multi-UE Paging with Real-Time Monitoring and ASN.1 Encoder/Decoder**

---
🧩 Components Architecture
text

Open5GS (5GC)
   ↑
  N2/N3
   ↑
  gNB (srsRAN)
   ↑
  ZMQ Transport
   ↑
GNU Radio Multi-UE
   ↑
UE-1   UE-2   UE-3

🖥️ System Requirements
bash

Ubuntu 22.04 LTS
RAM: ≥ 8 GB
CPU: ≥ 4 cores
Disk: ≥ 50 GB
sudo privileges

📁 Directory Structure
text

/home/r-309/
├── srsRAN_Project/          # 5G gNB + Open5GS
├── srsRAN_4G/               # UE implementation
├── srsRAN_config/           # Runtime configurations
├── asn1/                    # ASN.1 encoder/decoder
│   ├── asn/                 # ASN.1 specs
│   ├── encoder/
│   ├── decoder/
├── setup_paging_network.sh
├── monitor_paging.sh
├── test_paging.sh
└── /tmp/*.pcap             # Capture files

🔗 Reference Links

    GitHub Demo: srsRAN Multi-UE Setup

    Official Documentation: srsRAN Project Docs

📦 Installation & Setup
1. Install Required Tools
bash

sudo apt update
sudo apt install -y \
  build-essential \
  asn1c \
  wireshark \
  cmake \
  libfftw3-dev \
  libmbedtls-dev \
  libboost-program-options-dev \
  libconfig++-dev \
  libsctp-dev \
  libzmq3-dev \
  gnuradio \
  python3 \
  net-tools \
  iproute2

2. Docker Setup
bash

# Add Docker repository
sudo apt-get remove -y docker.io docker-doc docker-compose
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

Log out and log back in for Docker group changes
3. Build srsRAN Project (gNB)
bash

cd ~
git clone https://github.com/srsran/srsRAN_Project.git
cd srsRAN_Project
mkdir build && cd build
cmake .. -DENABLE_ZMQ=ON
make -j$(nproc)
sudo make install
sudo ldconfig

4. Build srsUE (UE Implementation)
bash

cd ~
git clone https://github.com/srsRAN/srsRAN_4G.git
cd srsRAN_4G
mkdir build && cd build
cmake ../ -DENABLE_EXPORT=ON -DENABLE_ZEROMQ=ON
make -j$(nproc)
sudo cp srsue/src/srsue /usr/bin/srsue
sudo chmod +x /usr/bin/srsue

5. Create Network Namespaces
bash

sudo ip netns add ue1
sudo ip netns add ue2
sudo ip netns add ue3

6. Fix /tmp Permissions
bash

sudo chmod 1777 /tmp

🔧 Configuration Files
File Locations
text

/root/srsRAN_config/gnb_zmq.yaml
/root/srsRAN_config/ue1_zmq.conf
/root/srsRAN_config/ue2_zmq.conf
/root/srsRAN_config/ue3_zmq.conf

UE Identity Mapping
text

UE  | IMSI            | IP         | NetNS
----|-----------------|------------|-------
UE1 | 001010123456780 | 10.45.0.2  | ue1
UE2 | 001010123456781 | 10.45.0.3  | ue2
UE3 | 001010123456782 | 10.45.0.4  | ue3

Port Mapping
text

Component | TX Port | RX Port
--------- | ------- | -------
gNB       | 2000    | 2100
UE1       | 2010    | 2001
UE2       | 2020    | 2011
UE3       | 2030    | 2021

🧠 ASN.1 Encoder/Decoder Implementation
1. ASN.1 Common Code Generation
bash

cd /root/asn1
mkdir -p asn
cp NR-RRC-Definitions.asn asn/
cp NGAP-Definitions.asn asn/
asn1c -gen-PER -fcompound-names -findirect-choice asn/*.asn

2. Build Encoder
bash

mkdir -p encoder
mv *.c *.h encoder/
cd encoder
gcc encoder.c *.c -o encoder -lm
./encoder

Expected Output:
text

ASN.1 Paging message encoded successfully
Encoding rule: PER
Output file: paging_message.per
Message size: 18 bytes

3. Build Decoder
bash

mkdir -p ../decoder
cp *.c *.h ../decoder/
cd ../decoder
gcc decoder.c *.c -o decoder -lm
./decoder paging_message.per

Expected Output:
text

ASN.1 Decode Successful
Message Type: Paging
UE Identity: 5G-S-TMSI
AMF Set ID: 1
AMF Pointer: 0
5G-TMSI: 0x00000001
Tracking Area Code: 7
Paging Record Count: 1

4. Decode Paging from PCAP
bash

tshark -r /tmp/gnb_ngap.pcap -T fields -e data > paging.hex
xxd -r -p paging.hex paging.per
./decoder paging.per

🚀 Runtime Execution (Mandatory Order)
Terminal 1 – Open5GS Core
bash

cd /root/srsRAN_Project/docker
docker compose up 5gc

Expected Output:
text

Open5GS daemon v2.7.0
AMF started
AMF SCTP listening on 10.53.1.2:38412
SMF started
UPF started
NRF started

Terminal 2 – GNU Radio
bash

cd /root/srsRAN_Project/utils/gnuradio
gnuradio-companion multi_ue_scenario.grc

▶ Click Run

Expected Output:
text

GNU Radio Companion 3.10.x
Executing flowgraph: multi_ue_scenario.grc
ZMQ connections established
Streaming samples...

Terminal 3 – gNB
bash

cd /root/srsRAN_Project/build/apps/gnb
sudo ./gnb -c /root/srsRAN_config/gnb_zmq.yaml

Expected Output:
text

--== srsRAN gNB ==--
Available radio types: zmq
Cell pci=1 bw=10 MHz dl_arfcn=368500
PLMN=00101 TAC=7
Connecting to AMF at 10.53.1.2:38412
NGAP connection established

Terminal 4–6 – UEs
bash

sudo ./srsue /root/srsRAN_config/ue1_zmq.conf
sudo ./srsue /root/srsRAN_config/ue2_zmq.conf
sudo ./srsue /root/srsRAN_config/ue3_zmq.conf

Expected UE Output:
text

Random Access Complete
Network attach successful. IP: 10.45.0.X

Terminal 7 – Real-Time Paging Monitor
bash

cd /root
chmod +x monitor_paging.sh
./monitor_paging.sh

Expected Monitor Output:
text

========================================
  Real-Time RRC & Paging Monitor
========================================

[12:34:56] [ACTV] UE now in RRC_CONNECTED
[12:35:16] [IDLE] UE released to RRC_IDLE state
[12:35:45] [PAGE] PAGING MESSAGE SENT
[12:35:45] [CONN] UE requesting connection
[12:35:46] [ACTV] UE now in RRC_CONNECTED

🧪 Paging Testing
Manual Paging Test
bash

# Wait for UE to go idle (25s inactivity)
ping 10.45.0.2 -c 3
sleep 25

# Trigger paging
ping 10.45.0.2 -c 1

Automated Paging Test
bash

cd /root
chmod +x test_paging.sh
./test_paging.sh

🔍 Wireshark Analysis
bash

wireshark /tmp/gnb_ngap.pcap &
wireshark /tmp/gnb_mac.pcap &
wireshark /tmp/ue1_mac.pcap &

Key Filters:

    ngap.procedureCode == 10 (Paging messages)

    mac-nr.paging (MAC layer paging)

    rrc.rrcSetupRequest (RRC connection requests)

📊 Expected Outputs Verification
1. gNB Paging Logs
text

[NGAP] Received Paging for UE 5G-S-TMSI
[RRC] Broadcasting Paging message
[MAC] PRACH detected

2. UE State Transitions
text

[IDLE] → [PAGE] → [CONN] → [ACTV]

3. Wireshark Paging Sequence
text

PRACH → RAR → RRCSetupRequest → RRCSetup → RRCSetupComplete

4. Paging Latency Measurement
text

NGAP Paging timestamp  : 12.123456 s
UE PRACH timestamp    : 12.135678 s
Paging Latency        : 12.22 ms

🛠️ Helper Scripts

Make scripts executable:
bash

chmod +x setup_paging_network.sh
chmod +x monitor_paging.sh
chmod +x test_paging.sh

🕐 Expected Timeline
text

Setup:          30 minutes
First run:      15 minutes
Paging test:    2 minutes per UE
Wireshark analysis: 20 minutes
Total:          ~2 hours

🧹 Shutdown Procedure
bash

# Terminal order:
Ctrl+C (UEs 4-6)
Ctrl+C (gNB Terminal 3)
Close GNU Radio (Terminal 2)
Ctrl+C (Monitor Terminal 7)
Ctrl+C (Open5GS Terminal 1)

# Cleanup
cd /root/srsRAN_Project/docker
docker compose down
sudo ip netns del ue1 ue2 ue3

✅ Final Validation Checklist
text

✔ UE enters RRC_IDLE after inactivity
✔ Paging triggered only for target UE
✔ UE wakes using PRACH procedure
✔ RRC connection reestablished
✔ ASN.1 decode matches Wireshark capture
✔ No false paging responses
✔ Real-time monitor shows correct state transitions

📁 Log & PCAP File Reference
Log Files:
text

/tmp/gnb.log
/tmp/ue1.log
/tmp/ue2.log
/tmp/ue3.log

PCAP Files:
text

/tmp/gnb_mac.pcap
/tmp/gnb_ngap.pcap
/tmp/gnb_rlc.pcap
/tmp/ue1_mac.pcap
/tmp/ue1_nas.pcap
/tmp/ue2_mac.pcap
/tmp/ue2_nas.pcap
/tmp/ue3_mac.pcap
/tmp/ue3_nas.pcap

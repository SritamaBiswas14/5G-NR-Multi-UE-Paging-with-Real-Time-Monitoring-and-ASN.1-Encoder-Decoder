5G NR Multi-UE Paging with Real-Time Monitoring and ASN.1 Encoder/Decoder

📌 Project Overview

This project implements a fully virtual 5G network on a single Ubuntu machine using software-defined radio concepts to demonstrate:

Multi-UE paging with real-time monitoring

ASN.1 encoding/decoding of NGAP and RRC messages

Standards-compliant 5G NR signaling without RF hardware

🚫 No RF hardware required

No USRP

No SIM

No antenna

✅ Everything runs entirely in software.

🧩 System Architecture
Open5GS (5G Core)
     ↑
   N2 / N3
     ↑
  srsRAN gNB
     ↑
 ZeroMQ Transport
     ↑
 GNU Radio (Multi-UE)
     ↑
 UE-1   UE-2   UE-3

🖥️ System Requirements
OS     : Ubuntu 22.04 LTS
RAM    : ≥ 8 GB
CPU    : ≥ 4 cores
Disk   : ≥ 50 GB
Access : sudo privileges

📁 Directory Structure
/home/r-309/
├── srsRAN_Project/          # 5G gNB + Open5GS
├── srsRAN_4G/               # UE implementation
├── srsRAN_config/           # Runtime configurations
├── asn1/                    # ASN.1 encoder/decoder
│   ├── asn/                 # ASN.1 specifications
│   ├── encoder/
│   └── decoder/
├── setup_paging_network.sh
├── monitor_paging.sh
├── test_paging.sh
└── /tmp/*.pcap              # Packet captures

🔗 Reference Links

GitHub Demo
https://github.com/devopsjourney23/my-srsproject-demo

Official srsRAN Documentation
https://docs.srsran.com/projects/project/en/latest/tutorials/source/srsUE/source/index.html#multi-ue-emulation

📦 Installation & Setup
1️⃣ Install Required Packages
sudo apt update
sudo apt install -y \
  build-essential asn1c wireshark cmake \
  libfftw3-dev libmbedtls-dev \
  libboost-program-options-dev \
  libconfig++-dev libsctp-dev \
  libzmq3-dev gnuradio python3 \
  net-tools iproute2

2️⃣ Docker Installation (for Open5GS)
sudo apt-get remove -y docker.io docker-doc docker-compose
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli \
  containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER


🔁 Logout & login again

3️⃣ Build srsRAN Project (gNB)
cd ~
git clone https://github.com/srsran/srsRAN_Project.git
cd srsRAN_Project
mkdir build && cd build
cmake .. -DENABLE_ZMQ=ON
make -j$(nproc)
sudo make install
sudo ldconfig

4️⃣ Build srsUE
cd ~
git clone https://github.com/srsRAN/srsRAN_4G.git
cd srsRAN_4G
mkdir build && cd build
cmake ../ -DENABLE_EXPORT=ON -DENABLE_ZEROMQ=ON
make -j$(nproc)
sudo cp srsue/src/srsue /usr/bin/srsue
sudo chmod +x /usr/bin/srsue

5️⃣ Create Network Namespaces
sudo ip netns add ue1
sudo ip netns add ue2
sudo ip netns add ue3

6️⃣ Fix /tmp Permissions
sudo chmod 1777 /tmp

🔧 Configuration Summary
UE Mapping
UE	IMSI	IP Address	Namespace
UE1	001010123456780	10.45.0.2	ue1
UE2	001010123456781	10.45.0.3	ue2
UE3	001010123456782	10.45.0.4	ue3
ZMQ Port Mapping
Component	TX	RX
gNB	2000	2100
UE1	2010	2001
UE2	2020	2011
UE3	2030	2021
🧠 ASN.1 Encoder / Decoder
Generate ASN.1 Code
cd /root/asn1
mkdir -p asn
cp NR-RRC-Definitions.asn NGAP-Definitions.asn asn/
asn1c -gen-PER -fcompound-names -findirect-choice asn/*.asn

Build Encoder
mkdir encoder
mv *.c *.h encoder/
cd encoder
gcc encoder.c *.c -o encoder -lm
./encoder

Build Decoder
mkdir ../decoder
cp *.c *.h ../decoder/
cd ../decoder
gcc decoder.c *.c -o decoder -lm
./decoder paging_message.per

🚀 Runtime Execution (Strict Order)

Open5GS Core

cd srsRAN_Project/docker
docker compose up 5gc


GNU Radio

gnuradio-companion multi_ue_scenario.grc


gNB

sudo ./gnb -c gnb_zmq.yaml


UEs

sudo srsue ue1_zmq.conf
sudo srsue ue2_zmq.conf
sudo srsue ue3_zmq.conf


Paging Monitor

./monitor_paging.sh

🧪 Paging Tests
Manual
ping 10.45.0.2 -c 3
sleep 25
ping 10.45.0.2 -c 1

Automated
./test_paging.sh

🔍 Wireshark Filters

ngap.procedureCode == 10

mac-nr.paging

rrc.rrcSetupRequest

📊 Expected Results

UE transitions: IDLE → PAGING → CONNECTED

Correct PRACH wake-up

ASN.1 decode matches PCAP

No false paging

🧹 Shutdown
Ctrl+C (UEs)
Ctrl+C (gNB)
Close GNU Radio
Ctrl+C (Monitor)
docker compose down
sudo ip netns del ue1 ue2 ue3

🎯 Project Outcome

✔ Multi-UE paging
✔ Real-time monitoring
✔ ASN.1 PER encoder/decoder
✔ PCAP-verified signaling
✔ Research-grade 5G NR testbed

Status: ✅ Complete & Production-Ready

🔄 Optional Extensions

Convert README + report to PDF

Viva questions & answers

Paging flow diagrams

Negative test cases

Latency benchmarking

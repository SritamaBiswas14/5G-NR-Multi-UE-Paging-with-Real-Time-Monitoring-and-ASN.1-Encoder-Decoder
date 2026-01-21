# 5G-NR-Multi-UE-Paging-with-Real-Time-Monitoring-and-ASN.1-Encoder-Decoder
# 📗 README.md

# **5G NR Multi-UE Paging with Real-Time Monitoring and ASN.1 Encoder/Decoder**

---

## 1. System Requirements

```bash
Ubuntu 22.04 LTS
sudo privileges

2. Directory Structure
bash

/root/
├── srsRAN_Project/
├── srsRAN_4G/
├── srsRAN_config/
├── asn1/
│   ├── asn/                # ASN.1 specs
│   ├── encoder/
│   ├── decoder/
├── setup_paging_network.sh
├── monitor_paging.sh
├── test_paging.sh
└── /tmp/*.pcap

3. File Locations Reference
Configuration Files
text

/root/srsRAN_config/gnb_zmq.yaml
/root/srsRAN_config/ue1_zmq.conf
/root/srsRAN_config/ue2_zmq.conf
/root/srsRAN_config/ue3_zmq.conf

Log Files
text

/tmp/gnb.log
/tmp/ue1.log
/tmp/ue2.log
/tmp/ue3.log

PCAP Files
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

4. Port Mapping
text

Component | TX Port | RX Port
--------- | ------- | -------
gNB       | 2000    | 2100
UE1       | 2010    | 2001
UE2       | 2020    | 2011
UE3       | 2030    | 2021

5. UE Identity Reference
text

UE  | IMSI            | IP         | NetNS
----|-----------------|------------|-------
UE1 | 001010123456780 | 10.45.0.2  | ue1
UE2 | 001010123456781 | 10.45.0.3  | ue2
UE3 | 001010123456782 | 10.45.0.4  | ue3

6. Install Required Tools
bash

sudo apt update
sudo apt install -y \
  build-essential \
  asn1c \
  wireshark \
  cmake

7. ASN.1 COMMON CODE GENERATION
bash

cd /root/asn1
mkdir -p asn

Copy ASN.1 files:
bash

cp NR-RRC-Definitions.asn asn/
cp NGAP-Definitions.asn asn/

Generate C code:
bash

asn1c -gen-PER -fcompound-names -findirect-choice asn/*.asn

8. ASN.1 ENCODER
Build Encoder
bash

mkdir -p encoder
mv *.c *.h encoder/
cd encoder
gcc encoder.c *.c -o encoder -lm

Run Encoder
bash

./encoder

Output:
text

paging_message.per

9. ASN.1 DECODER
Build Decoder
bash

mkdir -p ../decoder
cp *.c *.h ../decoder/
cd ../decoder
gcc decoder.c *.c -o decoder -lm

Decode PER File
bash

./decoder paging_message.per

10. Decode Paging from PCAP (Optional)
bash

tshark -r /tmp/gnb_ngap.pcap -T fields -e data > paging.hex
xxd -r -p paging.hex paging.per
./decoder paging.per

11. Create Network & Helper Scripts
Setup Script
bash

chmod +x setup_paging_network.sh
chmod +x monitor_paging.sh
chmod +x test_paging.sh

12. START NETWORK (MANDATORY ORDER)
Terminal 1 – Open5GS
bash

cd /root/srsRAN_Project/docker
docker compose up 5gc

Terminal 2 – GNU Radio
bash

cd /root/srsRAN_Project/utils/gnuradio
gnuradio-companion multi_ue_scenario.grc

▶ Click Run
Terminal 3 – gNB
bash

cd /root/srsRAN_Project/build/apps/gnb
sudo ./gnb -c /root/srsRAN_config/gnb_zmq.yaml

Terminal 4–6 – UEs
bash

sudo ./srsue /root/srsRAN_config/ue1_zmq.conf
sudo ./srsue /root/srsRAN_config/ue2_zmq.conf
sudo ./srsue /root/srsRAN_config/ue3_zmq.conf

Terminal 7 – REAL-TIME PAGING MONITOR
bash

cd /root
./monitor_paging.sh

You must see:
text

[IDLE] → [PAGE] → [CONN] → [ACTV]

13. MANUAL PAGING TEST
bash

ping 10.45.0.2 -c 3
sleep 25
ping 10.45.0.2 -c 1

Expected monitor output:
text

[IDLE]
[PAGE]
[CONN]
[ACTV]

Repeat for UE2 and UE3.
14. AUTOMATED PAGING TEST
bash

cd /root
./test_paging.sh

15. WIRESHARK ANALYSIS
bash

wireshark /tmp/gnb_ngap.pcap &
wireshark /tmp/gnb_mac.pcap &
wireshark /tmp/ue1_mac.pcap &

Filters:
text

ngap.procedureCode == 10
mac-nr.paging
rrc.rrcSetupRequest

16. Expected Timeline
text

Setup        : 30 min
First run    : 15 min
Paging test  : 2 min per UE
Wireshark    : 20 min
Total        : ~2 hours

17. Shutdown Procedure
bash

Ctrl+C (UEs)
Ctrl+C (gNB)
Close GNU Radio
Ctrl+C (Monitor)
docker compose down
sudo ip netns del ue1 ue2 ue3

18. Expected Terminal Outputs
18.1 Open5GS Core (Terminal 1)
text

Open5GS daemon v2.7.0

AMF started
AMF SCTP listening on 10.53.1.2:38412
SMF started
UPF started
NRF started

Paging trigger confirmation:
text

[AMF] Paging UE with 5G-S-TMSI
[AMF] Sending NGAP Paging message

18.2 GNU Radio Broker (Terminal 2)
text

GNU Radio Companion 3.10.x
Executing flowgraph: multi_ue_scenario.grc
ZMQ connections established
Streaming samples...

(No errors or disconnects must appear)
18.3 gNB Startup Output (Terminal 3)
text

--== srsRAN gNB ==--

Available radio types: zmq
Cell pci=1 bw=10 MHz dl_arfcn=368500
PLMN=00101 TAC=7

Connecting to AMF at 10.53.1.2:38412
NGAP connection established

UE Attach Logs
text

[NGAP] Initial UE message received
[RRC] RRCSetupRequest received
[RRC] RRCSetup sent
[RRC] RRCSetupComplete received

UE Inactivity → IDLE
text

[RRC] Inactivity timer expired
[RRC] Sending RRCRelease

Paging Reception
text

[NGAP] Received Paging for UE 5G-S-TMSI
[RRC] Broadcasting Paging message
[MAC] PRACH detected

18.4 UE Logs (Terminal 4 / 5 / 6)
Initial Attach
text

Random Access Transmission
Random Access Complete
Network attach successful. IP: 10.45.0.X

RRC Release
text

RRC connection released
Entering RRC_IDLE

Paging Response
text

Paging received
Random Access Transmission
RRC connection reestablished

18.5 Real-Time Paging Monitor Output (Terminal 7)
text

========================================
  Real-Time RRC & Paging Monitor
========================================

[12:34:56] [ACTV] UE now in RRC_CONNECTED
[12:35:16] [IDLE] UE released to RRC_IDLE state
[12:35:45] [PAGE] PAGING MESSAGE SENT
[12:35:45] [CONN] UE requesting connection
[12:35:46] [ACTV] UE now in RRC_CONNECTED

✔ This exact sequence confirms paging correctness
19. ASN.1 ENCODER OUTPUT
Encoder Execution
bash

./encoder

Output
text

ASN.1 Paging message encoded successfully
Encoding rule: PER
Output file: paging_message.per
Message size: 18 bytes

20. ASN.1 DECODER OUTPUT
Decoder Execution
bash

./decoder paging_message.per

Output
text

ASN.1 Decode Successful

Message Type: Paging
UE Identity: 5G-S-TMSI
AMF Set ID: 1
AMF Pointer: 0
5G-TMSI: 0x00000001
Tracking Area Code: 7
Paging Record Count: 1

21. ASN.1 Decode from PCAP Payload
bash

./decoder paging.per

Output
text

Decoded NGAP Paging Message

procedureCode: id-Paging (10)
UEPagingIdentity: fiveG-S-TMSI
TAI: PLMN=00101 TAC=7

✔ Matches Wireshark NGAP decode
22. Wireshark Verification Output
22.1 NGAP Paging (Core → gNB)

Filter:
text

ngap.procedureCode == 10

Expected fields:
text

Paging
 ├─ UE Paging Identity: fiveG-S-TMSI
 ├─ AMF Set ID
 ├─ AMF Pointer
 └─ TAI List (TAC = 7)

22.2 MAC Paging (Air Interface)

Filter:
text

mac-nr.paging

Expected:
text

PCCH-Message
 └─ Paging
    └─ PagingRecordList
       └─ UE Identity

22.3 UE Wake-Up Sequence

Observed sequence:
text

PRACH
RAR
RRCSetupRequest
RRCSetup
RRCSetupComplete

23. Paging Latency Measurement Example
text

NGAP Paging timestamp  : 12.123456 s
UE PRACH timestamp    : 12.135678 s
Paging Latency        : 12.22 ms

24. Final Validation Checklist
text

✔ UE enters RRC_IDLE after inactivity
✔ Paging triggered only for target UE
✔ UE wakes using PRACH
✔ RRC connection reestablished
✔ ASN.1 decode matches Wireshark
✔ No false paging responses

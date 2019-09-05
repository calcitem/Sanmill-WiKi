```
wmic cpu get caption, deviceid, name, numberofcores, maxclockspeed, status
Caption                               DeviceID  MaxClockSpeed  Name                                       NumberOfCores  Status  
Intel64 Family 6 Model 63 Stepping 2  CPU0      2600           Intel(R) Xeon(R) CPU E5-2697 v3 @ 2.60GHz  2              OK      
wmic MemoryChip get BankLabel, Capacity, MemoryType, TypeDetail, Speed, Tag
BankLabel  Capacity    MemoryType  Speed  Tag                TypeDetail  
None       4160749568  0                  Physical Memory 0  4           
None       1082130432  0                  Physical Memory 1  4           
systeminfo
Host Name:                 APPVYR-WIN
OS Name:                   Microsoft Windows Server 2016 Datacenter
OS Version:                10.0.14393 N/A Build 14393
OS Manufacturer:           Microsoft Corporation
OS Configuration:          Standalone Server
OS Build Type:             Multiprocessor Free
Registered Owner:          Windows User
Registered Organization:   
Product ID:                00377-90011-56893-AA303
Original Install Date:     4/7/2017, 7:51:17 PM
System Boot Time:          9/5/2019, 5:29:52 PM
System Manufacturer:       Microsoft Corporation
System Model:              Virtual Machine
System Type:               x64-based PC
Processor(s):              1 Processor(s) Installed.
                           [01]: Intel64 Family 6 Model 63 Stepping 2 GenuineIntel ~2600 Mhz
BIOS Version:              Microsoft Corporation Hyper-V UEFI Release v1.0, 11/26/2012
Windows Directory:         C:\Windows
System Directory:          C:\Windows\system32
Boot Device:               \Device\HarddiskVolume2
System Locale:             en-us;English (United States)
Input Locale:              en-us;English (United States)
Time Zone:                 (UTC) Coordinated Universal Time
Total Physical Memory:     4,999 MB
Available Physical Memory: 3,780 MB
Virtual Memory: Max Size:  5,831 MB
Virtual Memory: Available: 4,675 MB
Virtual Memory: In Use:    1,156 MB
Page File Location(s):     C:\pagefile.sys
Domain:                    WORKGROUP
Logon Server:              \\APPVYR-WIN
Hotfix(s):                 14 Hotfix(s) Installed.
                           [01]: KB3186568
                           [02]: KB3199986
                           [03]: KB4013418
                           [04]: KB4023834
                           [05]: KB4033393
                           [06]: KB4035631
                           [07]: KB4049065
                           [08]: KB4054590
                           [09]: KB4091664
                           [10]: KB4093137
                           [11]: KB4132216
                           [12]: KB4486129
                           [13]: KB4509091
                           [14]: KB4507459
Network Card(s):           3 NIC(s) Installed.
                           [01]: Hyper-V Virtual Ethernet Adapter
                                 Connection Name: vEthernet (HNS Internal NIC)
                                 DHCP Enabled:    Yes
                                 DHCP Server:     255.255.255.255
                                 IP address(es)
                                 [01]: 172.29.80.1
                                 [02]: fe80::9032:6463:4af4:9929
                           [02]: Hyper-V Virtual Ethernet Adapter
                                 Connection Name: vEthernet (DockerNAT)
                                 DHCP Enabled:    No
                                 IP address(es)
                                 [01]: 10.0.75.1
                                 [02]: fe80::bc23:42a2:fff3:a8a9
                           [03]: Microsoft Hyper-V Network Adapter
                                 Connection Name: Ethernet 7
                                 DHCP Enabled:    No
                                 IP address(es)
                                 [01]: 10.0.0.4
                                 [02]: fe80::d909:4d62:c9c1:5036
Hyper-V Requirements:      A hypervisor has been detected. Features required for Hyper-V will not be displayed.
Discovering tests...OK
```
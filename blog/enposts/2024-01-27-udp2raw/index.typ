// Building a Virtual Private Network with udp2raw + Wireguard
#import "/template-en.typ":*
#doc-template(
title: "Building a Virtual Private Network with udp2raw + Wireguard",
date: "January 27, 2024",
body: [

== Server Configuration

Wireguard configuration:

```
[Interface]
Address = 10.7.1.1/24
ListenPort = 51820
PrivateKey = *************
MTU=1350

[Peer]
PublicKey = *************
AllowedIPs = 10.7.1.2/32
```

Enable NAT using iptables:

```
#!/bin/bash

IPT=iptables
SUB_NET=10.7.1.0/24
IN_FACE=eth0
WG_FACE=wg0
WG_PORT=51820

sudo $IPT -t nat -I POSTROUTING 1 -s $SUB_NET -o $IN_FACE -j MASQUERADE
sudo $IPT -I INPUT -i $WG_FACE -j ACCEPT
sudo $IPT -I INPUT -i lo -j ACCEPT
sudo $IPT -I FORWARD -i $IN_FACE -o $WG_FACE -j ACCEPT
sudo $IPT -I FORWARD -i $WG_FACE -o $IN_FACE -j ACCEPT
sudo $IPT -I INPUT -i $IN_FACE -p udp --dport $WG_PORT -j ACCEPT
sudo $IPT -I INPUT -i lo -p udp --dport $WG_PORT -j ACCEPT
```

Enable IP forwarding in `/etc/sysctl.conf`:

```
net.ipv4.ip_forward = 1
```

Convert to fakeTCP using udp2raw:

```
sudo ./udp2raw -s \
    -l 0.0.0.0:53388 \
    -r 127.0.0.1:51820 \
    -k "YourPasswordHere" \
    --fix-gro
```

== Client Configuration

udp2raw client configuration:

```
sudo ./udp2raw -c \
    -l 127.0.0.1:53388 \
    -r [SERVER IP]:53388 \
    -k "YourPasswordHere" \
    --fix-gro
```

Wireguard configuration:

```
[Interface]
Address = 10.7.1.2/32
PrivateKey = **********
MTU=1350

[Peer]
PublicKey = **********
Endpoint = 127.0.0.1:53388
AllowedIPs = 10.7.1.1/32
```

])

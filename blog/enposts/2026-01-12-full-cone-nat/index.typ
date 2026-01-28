// Curing Various Online Gaming Troubles
#import "/template-en.typ": doc-template

#doc-template(
title: "Curing Various Online Gaming Troubles",
date: "January 12, 2026",
body: [

a.k.a. How to turn your gaming PC's NAT type into NAT1 based on a VPS.

= Background

Online gaming should be a joy, but when the connection is unstable and latency is high, it becomes painful. The reason is that most online games on Steam, to save costs, do not have central servers like traditional online games but use peer-to-peer (P2P) connections. However, home broadband often has complex firewalls and NAT, posing many obstacles to mutual connection. Secondly, the data packets sent between players are P2P packets between home broadbands. These packets are not prioritized by network operators and are discarded as soon as there is slight network congestion.

#image("1.jpg", width: 75%)

In this case, it would be much better if you run the server yourself on a VPS, such as for Factorio or Minecraft.

But this approach cannot be extended to all games. Many games do not support running a Linux server yourself. At this time, *Static NAT* can come in handy. Unlike the *Dynamic NAT* common on home broadband routers, static NAT is one-to-one, without any IP or port restrictions. After configuring static NAT between the VPS server and the gaming PC as the online host, the VPS server serving as the gateway becomes the "incarnation" of the gaming PC on the network. Whatever data the VPS receives, regardless of the port, will be forwarded as-is to the gaming PC serving as the host. And vice versa for data packets sent by the gaming PC. In this way, although the host for the online game is running on your home computer in front of you, the effect on the network is similar to hosting the online server directly on the VPS.

#image("2.jpg", width: 75%)

= Key Generation

First, install `wireguard-tools` on the VPS.

```
apt install wireguard-tools
```

Then create a pair of Wireguard keys using the `wg genkey` and `wg pubkey` commands:

```
sk1=$(wg genkey)
pk1=$(echo $sk1 | wg pubkey)
echo $sk1
echo $pk1
```

Where `sk1` is the private key and `pk1` is the public key, which need to be recorded as the server's keys.

Then repeat the process to generate another set, `sk2` and `pk2`, as the keys for the gaming PC.

= VPS Configuration

First, as for how to choose a VPS, generally prioritize a data center closer to the gaming PC. According to the characteristics of game servers, it is best to choose a network billing model that charges by traffic and does not limit bandwidth. Then, turn off the firewall provided by the VPS provider; we will configure the firewall policy ourselves.

Let's configure Wireguard first: with administrator privileges, create a Wireguard configuration file:

```
sudo vim /etc/wireguard/wg0.conf
```

The content of the file is as follows:

```
[Interface]
PrivateKey = [Insert sk1]
Address = 10.1.1.1/32
MTU=1420
ListenPort = 51820

[Peer]
PublicKey = [Insert pk2]
AllowedIPs = 10.1.1.2/32
```

Then use `ip addr` to check the Ethernet interface on the VPS, which is usually `eth0`. Suppose its IP address is `111.111.111.111`.

Add these commands to the startup script. `111.111.111.111` needs to be replaced with the corresponding address on the Ethernet port. The VPS may also have static NAT, so the public IP address of the VPS and the Ethernet port address of the VPS are not necessarily the same. Here, the *Ethernet port address* of the VPS is used.

```
sysctl -w net.ipv4.ip_forward=1

wg-quick up wg0
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT

iptables -t nat -A POSTROUTING \
    -o eth0 -s 10.1.1.2 \
    -j SNAT --to-source 111.111.111.111

iptables -t nat -A PREROUTING \
    -i eth0 -p udp --dport 1025:65535 \
    -j DNAT --to-destination 10.1.1.2
iptables -t nat -A PREROUTING \
    -i eth0 -p tcp --dport 1025:65535 \
    -j DNAT --to-destination 10.1.1.2

iptables -t nat -I PREROUTING \
    -i eth0 -p udp --dport 51820 -j RETURN
```

Please consult an AI for how to create a startup script using systemd.

Then restart the VPS.

= Gaming PC Configuration

Here we take Windows as an example. The configuration on Linux is basically the same.

Suppose the public address of the VPS is `123.123.123.123`. The `123.123.123.123` in the following example should be replaced with the actual IP address of the VPS server. The VPS may also have static NAT, so the public IP address of the VPS and the Ethernet port address of the VPS are not necessarily the same. Here, the *public address* of the VPS is used.

First, download and install the Wireguard client for Windows: #link("https://download.wireguard.com/windows-client/")[Download Link].

Then calculate the AllowedIPs for Wireguard. You can use #link("https://www.procustodibus.com/blog/2021/03/wireguard-allowedips-calculator/", "a web tool") for this. Enter `0.0.0.0/0` in Allowed IPs. Enter `192.168.0.0/16, 123.123.123.123/32` in Disallowed IPs, then click "Calculate" and copy the large string of `AllowedIPs = ...`.

Create a file with a `.conf` extension, for example, `wg0.conf`, open it with Notepad, and enter:

```
[Interface]
PrivateKey = [Insert sk2]
Address = 10.1.1.2/32
DNS = 8.8.8.8

[Peer]
PublicKey = [Insert pk1]
AllowedIPs = [Insert the large string just calculated]
Endpoint = 123.123.123.123:51820
PersistentKeepalive = 25
```

Load this configuration file with the Wireguard client and click "Activate." At this point, the configuration should theoretically be complete.

If there are any transparent proxy tools like Clash, it's best to exit them here, as they might cause interference.

At this time, you can search for "NAT test" on a search engine and find a WebRTC-based NAT detection website to check the current NAT type. If it goes smoothly, it should show as "NAT1" or "Full Cone NAT." That counts as success. Now start the online game, and in most cases, various troubles should disappear.

])

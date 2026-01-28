// IPv4/IPv6 Dual Stack Soft Router Based on Debian 12
#import "/template-en.typ":*
#doc-template(
title: "IPv4/IPv6 Dual Stack Soft Router Based on Debian 12",
date: "March 24, 2024",
body: [

= Origin

Recently, I bought a cheap industrial control mini-PC with an Intel Celeron processor. This host has two network cards, which makes it very suitable for use as a router. Since my old router was quite aged and did not support IPv6, I decided to replace it with this machine. The original wireless router is now only used as an access point. Normally, one would choose a dedicated router operating system like OpenWRT, but I also want this machine to handle many server functions. Debian is more familiar to me, though the trade-off is that there is no convenient one-stop web configuration interface, and everything must be done manually.

So, here I record how to use Debian to configure a usable server as a router.

= Basic Settings

This host has two network cards, named `enp2s0` and `enp4s0` in the operating system. Theoretically, with VLANs, a single network port could serve as a router. However, in my experience, a one-arm router based on VLAN is troublesome to configure. Following the principle of "don't overcomplicate things," I recommend using two network cards. If the motherboard has only one network card, a USB 3.0 network card can serve the same purpose.

Here, I use `enp2s0` as the WAN port, with the network segment assigned by the ISP. `enp4s0` is the LAN port, with the IPv4 segment `192.168.31.0/24` and the router's IP address `192.168.31.63`. The IPv6 segment is `fc61:5887:1acd:4260::/64`, and the router's own IPv6 address is `fc61:5887:1acd:4260::1`.

The IPv4 segment can be chosen from `192.168.*.*` as long as there is no conflict. The private IPv6 segment starts with `fc`, so any segment starting with `fc` will work, and the rest can be filled arbitrarily. I used a randomly generated 64-bit segment. If you want to use `fc11:4514:1919:8100::/64`, that's fine too.

= WAN Settings

Debian now uses the `networking` service for network configuration. Edit `/etc/network/interfaces` and add:

```
allow-hotplug enp2s0
iface enp2s0 inet dhcp
iface enp2s0 inet6 dhcp
```

Then run:

```
sudo systemctl restart networking
```

= LAN Settings

Similarly, edit `/etc/network/interfaces` and add:

```
allow-hotplug enp4s0
iface enp4s0 inet static
    address 192.168.31.63/24
iface enp4s0 inet6 static
    address fc61:5887:1acd:4260::1/64
```

Then run:

```
sudo systemctl restart networking
```

= IP Forwarding

Edit `/etc/sysctl.conf` and add:

```
net.ipv4.ip_forward = 1
net.ipv6.conf.enp2s0.accept_ra = 2
net.ipv6.conf.all.forwarding=1
```

Apply the configuration immediately:

```
sudo sysctl -p
```

However, after this takes effect, for some reason, the default routing rule might disappear. I am not sure what the problem is, so I choose to manually add the routing rule:

```
sudo ip -6 route add \
    default via fe80::1 \
        dev enp2s0 \
        proto ra \
        metric 1024 \
        hoplimit 255 \
        pref medium
```

The routing rules may vary in different network environments. You can use the following command to see what the current routing rule is before enabling IPv6 forwarding:

```
sudo ip -6 route | grep default
```

Also, this command should be added to a startup script.

= NAT

Linux firewall configuration has moved into the era of `nftables`, but I haven't learned `nftables` much yet, so I chose to use the `iptables` compatibility layer.

IPv4 NAT configuration:

```
IPT=/usr/sbin/iptables
SUB_NET=192.168.31.0/24
WAN_FACE=enp2s0
LAN_FACE=enp4s0

$IPT -t nat -I POSTROUTING 1 -s $SUB_NET -o $WAN_FACE -j MASQUERADE
$IPT -I INPUT -i $LAN_FACE -j ACCEPT
$IPT -I FORWARD -i $WAN_FACE -o $LAN_FACE -j ACCEPT
$IPT -I FORWARD -i $LAN_FACE -o $WAN_FACE -j ACCEPT
```

IPv6 NAT configuration:

```
IPT=/usr/sbin/ip6tables
SUB_NET=fc61:5887:1acd:4260::/64
WAN_FACE=enp2s0

$IPT -t nat -A POSTROUTING -o $WAN_FACE -j MASQUERADE
```

These are bash scripts and should also be added to a startup script.

In theory, IPv6 does not need NAT at all, but because I can't quite figure out my ISP's IPv6 address assignment rules, I chose a safe NAT instead.

= DHCP Server

Debian 12 provides a DHCP server `isc-dhcp-server`:

```
sudo apt install isc-dhcp-server
```

First, modify `/etc/default/isc-dhcp-server`. Here we only need IPv4:

```
INTERFACESv4="enp4s0"
INTERFACESv6=""
```

Then edit `/etc/dhcp/dhcpd.conf`:

```
option domain-name-servers 223.5.5.5;

subnet 192.168.31.0 netmask 255.255.255.0 {
    range 192.168.31.100 192.168.31.200;
    option routers 192.168.31.63;
}
```

The DNS server chosen here is Alibaba Cloud's server, mainly for use in China. If abroad, you can directly use `8.8.8.8` or `1.1.1.1`.

For IPv6, DHCP is not needed, and you can directly use the #link("https://en.wikipedia.org/wiki/IPv6")[Stateless Address Autoconfiguration (SLAAC)] of IPv6.

First, install `radvd`:

```
sudo apt install radvd
```

Then create the configuration `/etc/radvd.conf`:

```
interface enp4s0 {
    AdvSendAdvert on;
    MinRtrAdvInterval 30;
    MaxRtrAdvInterval 100;
    prefix fc61:5887:1acd:4260::/64 {
        AdvOnLink on;
        AdvAutonomous on;
        AdvRouterAddr off;
    };
};
```

Finally, restart the DHCP server and `radvd`:

```
sudo systemctl restart isc-dhcp-server
sudo systemctl restart radvd
```

If these two servers can operate normally, the soft router is successfully completed.
])

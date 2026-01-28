// Becoming a BT Cyber Bodhisattva Without a Public IP
#import "/template-en.typ":*
#doc-template(
title: "Becoming a BT Cyber Bodhisattva Without a Public IP",
date: "January 28, 2024",
body: [

When using BitTorrent to download resources, the client enters a seeding state to upload after the download ends. At this time, BT connections are generally incoming connections. If you don't have a public IP, there is no way to upload. The China Mobile broadband I am currently using is a broadband without a public IP.

However, I have several VPS servers with public IPs, and these servers can be used as stepping stones.

First, I established a mesh VPN network using Tailscale. My laptop's Tailscale IP is 100.64.0.13, and the VPS server's Tailscale IP is 100.64.0.30.

Using `tmux` + `ssh`, a SOCKS5 proxy can be quickly set up on the VPS server:

```
ssh -D 100.64.0.30:1080 127.0.0.1
```

The BitTorrent client I use is qBitTorrent, and I have fixed the listening port to 42318. Using the Nginx stream module, port reverse proxy can be set up:

```
stream {
	server {
		listen 0.0.0.0:42318;
		proxy_pass 100.64.0.13:42318;
	}
	server {
		listen 0.0.0.0:42318 udp;
		proxy_pass 100.64.0.13:42318;
	}
}
```

Then configure qBitTorrent.

Tools -> Preferences -> Connection: Set the listening port to 42318, set the proxy server to 100.64.0.30, port 1080, use the proxy server for peer connections, and use the proxy for hostname lookup.

Tools -> Preferences -> BitTorrent: Add tracker servers, you can refer to #link("https://github.com/ngosang/trackerslist")[this list].

Tools -> Preferences -> Advanced: Since all incoming connections will have the same IP after being proxied by Nginx, select "Allow multiple connections from the same IP address" here.

After applying the settings and restarting qBitTorrent, you can start your charity as a BT Cyber Bodhisattva.

])

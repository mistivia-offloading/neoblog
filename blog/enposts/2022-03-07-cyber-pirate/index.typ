// Cyber Pirate Navigation Guide
#import "/template-en.typ":doc-template

#doc-template(
title: "Cyber Pirate Navigation Guide",
date: "March 7, 2022",
body: [

Becoming a pirate and obtaining pirated resources is not a disgraceful thing. In the world we live in today, literature and art are controlled by monopoly giants and filled with DRM and censorship. At this time, properly obtaining pirated versions, using money where it counts, and supporting the independent authors you like can be seen as a form of resistance. To obtain pirated resources, peer-to-peer download is one of the most important ways.

However, in many developed countries, especially in the European Union, North America, and Japan, becoming a pirate also carries legal risks, and in some regions, it may even be criminalized.

= Choosing a Protocol

There are two types of popular peer-to-peer download protocols today:

- BitTorrent/Magnet
- eMule

The former is the famous "BT download" and the derived "magnet link". The latter is "eMule". On the Chinese Internet, the name "Dianlv" (Electronic Donkey) might be more widely spread. As for "Dianlv", "eMule", VeryCD, etc., there is a long history behind them, which will not be repeated here. Given that eMule has declined compared to the former, we choose BitTorrent/Magnet here.

= Recommended Software

There are many software programs that can perform BitTorrent/Magnet downloads (hereinafter referred to as BT downloads), and some can be listed offhand:

- #link("https://www.utorrent.com/")[µTorrent]
- #link("https://transmissionbt.com/")[Transmission]
- #link("https://deluge-torrent.org/")[Deluge]
- #link("https://www.qbittorrent.org/")[qBitTorrent]
- #link("https://www.bitcomet.com/en")[BitComet]
- #link("https://www.xunlei.com/")[XunLei]

Among them, the last one, XunLei, is our biggest enemy because it "leeches" from elsewhere.

The working principle of BT is "all for one, one for all," that is, after downloading from elsewhere, it will be uploaded to other users who have not completed the download. "Leechers" will only download but not upload, and are despised by everyone.

qBitTorrent is not only open-source but also has an #link("https://github.com/c0re100/qBittorrent-Enhanced-Edition")[Enhanced Edition fork]. It can effectively identify leeching clients like XunLei and QQ Xuanfeng, and can also block unknown BT clients with one click (leechers usually deliberately do not fill in their client name and version number).

Therefore, this enhanced version of qBitTorrent is chosen here for introduction. (#link("https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases")[Latest download address on GitHub])

Download address for version 4.4.0.10 (may not be the latest):

- #link("https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-4.4.0.10/qbittorrent_enhanced_4.4.0.10_x64_setup.exe")[Windows (x64)]
- #link("https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-4.4.0.10/qBitTorrent-Enhanced-Edition.AppImage")[Linux (AppImage)]
- #link("https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/release-4.4.0.10/qBitTorrent_enhanced-4.4.0.10.dmg")[macOS]

As for installation, there is not much to say, as you only need to click "Next".

= Software Configuration

The configuration menu is opened here:

#image("./images/0005.jpg", width: 80%)

First, enable the advanced function of blocking leeching clients:

#image("./images/0006.jpg", width: 80%)

Then some configurations related to the BT protocol. In order to find more users, we need to turn on the functions that can be used to find users:

#image("./images/0007.jpg", width: 80%)

Finally, some tracker servers need to be added.

Let me explain a little bit what a tracker server is. As mentioned before, the essence of BT download is "all for one, one for all." BT files and magnet links are actually "fingerprints" of the files to be downloaded. We need to shout this fingerprint in the "square" to know who owns the file, so as to exchange what we have for what we need. Tracker servers are such "squares." Many BT files and magnet links will come with a tracker server list, but more is always better; moreover, some magnet links do not come with a tracker server list. At this time, we can only find peers with the same resources through peer-to-peer protocols like DHT, and this process is like fumbling slowly in the dark.

There is a #link("https://github.com/ngosang/trackerslist")[very useful public tracker server list] on GitHub. We just need to copy the content in #link("https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt")[this file] to our qBitTorrent configuration:

#image("./images/0008.jpg", width: 80%)

= How to Download

The most famous pirated resource site is #link("https://thepiratebay.org/index.html")[The Pirate Bay].

Taking last month's flop "The Matrix Resurrections" as an example, you can quickly get results after searching. Then, right-click the magnet icon and copy to get the magnet link.

#image("./images/0009.jpg", width: 80%)

Next, open qBitTorrent and add the magnet link:

#image("./images/0010.jpg", width: 80%)

#image("./images/0011.jpg", width: 80%)

Finally, choose where to save the file and click OK, and the download should start.

#image("./images/0012.jpg", width: 80%)

Of course, if it is a niche resource, the download may not start for a long time or the speed may be very slow. In this case, you can only pray.

In addition, there is a "heretical" way. Many domestic cloud disks provide magnet link offline download functions. If someone has uploaded this file to a domestic cloud disk and it has not been censored yet, you can download it directly using the cloud disk:

#image("./images/0013.jpg", width: 80%)

#image("./images/0014.jpg", width: 80%)

= How to Find Resources

In addition to the aforementioned Pirate Bay, #link("https://www.proxyrarbg.org/index80.php")[RARBG] is also a good place (Note in 2023: the site has been closed due to the Russia-Ukraine war). If it is an anime or ACG-related resource, Western fansub groups will post it on #link("https://nyaa.si")[nyaa.si]. Domestic fansub groups also appear on #link("https://share.dmhy.org/")[Dmhy].

In addition, Google is actually very useful. Using Chinese movie names + "magnet link" as keywords for retrieval can yield a huge number of results. Generally, if it is an English website, providing magnet links will lead to DMCA notices from copyright owners, causing the resources to be removed by Google. However, Chinese resources are a legal vacuum:

#image("./images/0015.jpg", width: 80%)

However, network resources vary in quality, so it is better to be careful with identification.

]
)

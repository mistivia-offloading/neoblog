// How to Use Newsgroup
#import "/template-en.typ":*

#doc-template(
title: "How to Use Newsgroup",
date: "June 4, 2025",
body: [

= TL;DR.

If you already know what a newsgroup is, please use an NNTP client to connect directly to the following address:

```
nntps://raye.mistivia.com:563/sharknews
```

= What is a Newsgroup

A newsgroup is a public discussion system based on the NNTP protocol, also known as Usenet. It is similar to a huge bulletin board/forum where users can post articles in different "groups", and other users can read and reply to these articles.

The 1980s and early 1990s were the golden age of newsgroups. At that time, it was almost the only large-scale public discussion platform on the Internet, witnessing many of the earliest storms of the Internet, such as the rise of the open-source movement. The archives of newsgroups at that time are still a treasure trove for exploring early Internet culture. However, with the rise of the Web, newsgroups have gradually faded from the historical stage.

= My Newsgroup Server

Purely for fun, I set up a newsgroup server deployed on the server "raye.mistivia.com". This newsgroup can be used as a knowledge base, a bulletin board, or even a chat room. Although not as powerful as the World Wide Web, it can provide some unique "retro" fun.

= User Guide

Although it is an ancient protocol that is almost obsolete, many clients still support newsgroups, the most famous of which is Thunderbird. So here we take Thunderbird as an example to introduce how to use newsgroups.

- #link("https://www.thunderbird.net/")[Thunderbird Official Website]

== Setting up the Server

After opening Thunderbird, click the menu in the upper right corner. Select "Account Settings" or "Add Account".

#image("addaccount.jpg", width:70%);

Select "Newsgroup".

#image("newsgroup.jpg", width:70%);

Enter your nickname and email address.

#image("id.jpg", width:70%);

Enter the server address: "raye.mistivia.com".

#image("serveraddr.jpg", width:70%);

After adding, restart Thunderbird.

== (Optional) Configuring TLS Secure Connection

In Thunderbird, new newsgroup servers use insecure plain text connections by default, so it is best to change to a secure TLS connection.

Select the newsgroup server in the left sidebar and click "Account Settings".

#image("accountsetting.jpg", width:70%);

Then select "Server Settings" and change "Connection security" to "SSL/TLS".

#image("tls.jpg", width:70%);

== Subscribing to Newsgroups

Right-click on the newsgroup server you just added and select "Subscribe".

#image("subscribe.jpg", width:70%);

Check the "sharknews" group and then confirm.

#image("sharknews.jpg", width:70%);

== Posting

Select the "sharknews" group in the left sidebar, and then click "Write":

#image("write.jpg", width:70%);

You can then post to the newsgroup.

#image("compose.jpg", width:70%);

== Replying to Posts

If you want to reply to a post, select the post you want to reply to, and then click "Reply to Group". You can then follow up in the newsgroup.

#image("reply.jpg", width:70%);

])

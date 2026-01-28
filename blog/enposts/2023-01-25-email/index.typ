// My Email Workflow
#import "/template-en.typ": *

#doc-template(
title: "My Email Workflow",
date: "January 25, 2023",
body: [

= Software to be Installed

- Maildrop
- Fetchmail
- Msmtp
- Mutt

The above software is available in almost all Linux distributions.

```
sudo yum install maildrop fetchmail msmtp mutt
```

= Receiving Emails

Two pieces of software are used for receiving emails. First is `fetchmail`, which downloads emails from the server using IMAP or POP3 protocols, and then hands them over to `maildrop` for processing. By default, user emails in Unix-like operating systems are stored in `/var/spool/mail/username`. This is also where `maildrop` saves emails by default. If there are not many emails and no special email filtering needs, you don't need to configure `maildrop` and just use the default settings.

As for `fetchmail`, configure it to download unread emails using the IMAP protocol from the `INBOX` and `JUNK` directories. At the same time, do not delete emails, just set them to read:

```
poll smtp.example.org proto imap
    username "user@example.org"
    password "xxxxxxxx"
    options ssl keep
    mda "/usr/bin/maildrop";

poll smtp.example.org proto imap
    username "user@example.org"
    password "xxxxxxxx"
    options ssl keep
    folder JUNK
    mda "/usr/bin/maildrop";
```

Then run `fetchmail` periodically to check for emails.

= Reading Emails

You can use `mutt` to read emails. By default, `mutt` will examine the `/var/spool/mail/username` file. To display emails in reverse order by session and time, you can set `mutt`'s email sorting method. Add the following to `~/.muttrc`:

```
set folder=~/mail
set sort_aux=last-date-received       
set sort=threads
set sort_re
```

For unwanted emails, you can press the `d` key to mark them for deletion; if you want to move emails to other mailbox files in batches, you can press the `t` key to tag the emails, then press the `;` key, and finally press the `s` key to move the emails.

For emails containing HTML or other attachments, you can use the pipe function to hand them over to the corresponding application for display.

For example, for HTML emails, you can press the `v` key to enter the attachment interface, select the `text/html` attachment, press the `|` key, and then use a custom script to let Firefox display the email:

```
#!/bin/bash

cat > /tmp/hmail.html
firefox /tmp/hmail.html
```

As for images, you can let Eye of Gnome or another image viewer display them:

```
#!/bin/bash

cat > /tmp/img
eog /tmp/img
```

Or just save them directly:

```
cat > [filename]
```

= Sending Emails

Unix-like systems use the `sendmail` command by default to send emails, and `msmtp` also provides a `sendmail`-compatible usage. First, configure `~/.msmtprc`:

```
account mymail
tls on
auth on
host smtp.exmaple.org
port 587
user user@example.org
from user@example.org
password xxxxxxxx
logfile /home/user/.msmtp.log

account default : mymail
```

Then configure your own name by adding the following to `~/.muttrc`:

```
set from="Your Fullname Here <user@example.org>"
```

Subsequently, use

```
mutt target@example.org
```

to start editing the email, and finally press the `y` key to send.

= Git Email Workflow

If you want to contribute patches to open-source projects using mailing lists, you need to use the `git send-email` function. Git will use `sendmail` to send emails by default. If `msmtp` is configured, you can use it directly.

If you want to send the content of the last two commits to a mailing list, just run:

```
git send-email --to target@example.org HEAD~2..HEAD
```

= Address Book

Linux distributions generally provide a command-line address book application: "abook". Abook can interoperate with Mutt. However, I personally don't think it's very useful. It's better to just use text files and search with `grep`. So I won't repeat it here.

= Why Bother?

Finally, let's talk about why you should receive and send emails in the terminal.

First, email is not a complex thing. In most cases, it's just plain text. Using a heavy and slow client for such simple information is a bit like killing a fly with a sledgehammer.

Second, in the terminal, the tools used to receive and send emails are traditional Unix tools and their successors, which are very easy to hack and customize to meet specific needs. For example, you can customize a set of email filtering rules or use a script to send emails to yourself. If you are a heavy user of email, this workflow will be very convenient.

])

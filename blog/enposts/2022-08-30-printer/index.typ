// Let's Pass Notes
#import "/template-en.typ":doc-template

#doc-template(
title: "Let's Pass Notes",
date: "August 30, 2022",
body: [

Previously, there were two thermal printer products called Memobird and Paperang, and the most interesting feature in them was passing notes. However, for some reason, the note-passing feature of Memobird was taken offline, and the product focus changed to a printer for students' incorrect questions. But this feature is not difficult to implement, so here we will make one ourselves using a Telegram bot and a POS printer.

#image("./images/0001.jpg", width: 80%)

= Applying for a Telegram Bot

First, open BotFather and use the `/newbot` command to apply for creating a bot, as shown in the figure:

#image("./images/0002.jpg", width: 80%)

After entering the name and ID, you will get a token, which needs to be saved.

= Purchasing a POS Printer

The POS printers on the market are mainly thermal printers. However, thermal printers have two disadvantages:

- The coating on thermal paper is a low-toxicity material.
- Thermal paper will fade after a few weeks.

But the advantage is that it's cheap:

#image("./images/0003.jpg", width: 80%)

In addition, there are dot matrix receipt printers, which only need ordinary paper tape and will not fade, often used for invoice printing. However, the price is also much higher:

#image("./images/0004.jpg", width: 80%)

The specific choice depends on personal preference. These printers are all connected to the computer through a USB port and look the same at the software level.

= Testing the Printer

Here I chose to use the printer under the Linux operating system. Because Linux is suitable for embedded systems, you can use a low-power single-board computer like Raspberry Pi. In addition, the Linux kernel comes with a USB printer driver, which is even more convenient than Windows. After connecting the printer to the computer with a USB cable, use the `dmesg` command to view the device information:

```
$ sudo dmesg |grep -i printer
[ 2.249791] usb 2-2.1: Product: USB PRINTER
[ 2.249792] usb 2-2.1: Manufacturer: Printer
[ 3.826349] usblp 2-2.1:1.0: usblp0: USB Bidirectional printer 
    dev 4 \ if 0 alt 0 proto 2 vid 0x0483 pid 0x070B
```

As shown in the above command, a `usblp0` printer device has been added. At this time, a character device will also appear in the `/dev/usb` directory:

```
$ ls -l /dev/usb/
total 0
crw-rw---- 1 root root 180, 0 Aug 29 05:16 lp0
```

Then change the owner of this device to yourself:

```
sudo chown $USER:$USER /dev/usb/lp0
```

You can start printing by inputting text into this character device:

```
echo "The quick brown fox jumps over the lazy dog." > /dev/usb/lp0
```

If you need to input Chinese, please note that most thermal printers in China only support the GBK character set, and encoding conversion is required:

```
echo "I can swallow glass, it does not hurt me." | iconv -i utf-8 -t gbk > /dev/usb/lp0
```

After the operating system restarts, the owner of the device will revert to root, so you need to modify the udev configuration:

```
echo -e KERNEL=="lp0", \SUBSYSTEM=="usbmisc", \ACTION=="add", \OWNER=="$USER", \
GROUP=="$USER" \ | sudo tee -a /etc/udev/rules.d/99-perm.rules
```

= Writing the Telegram Bot

Writing a Telegram bot is easiest with Python!

First, download the Telegram bot library:

```
sudo pip3 install python-telegram-bot
```

Actually, tools like `virtualenv` should be used, but I installed it globally here for convenience.

Then the code:

```
# The token needs to be changed to the one you applied for previously
TOKEN='xxxxxx'

import logging
from time import localtime, strftime
from telegram import ForceReply, Update
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters

logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)

def printer_output(content):
    # Need to open the device file with GBK encoding
    with open('/dev/usb/lp0', 'w', encoding='gbk') as fp:
        fp.write(content)

def start(update, context):
    user = update.effective_user
    update.message.reply_text("Let's pass notes!")

def print_msg(update, context):
    if update.message.text is None or update.effective_user is None:
        update.message.reply_text('Error: Unsupported message type')
        return
    user = update.effective_user
    name = user.first_name
    if user.last_name is not None:
        name = name + ' ' + user.last_name
    # Ignore non-GBK characters in the name
    name = name.encode("gbk", errors='ignore').decode("gbk")
    if user.username is not None:
        name = name + ' @' + user.username
    content = '-------------------------\n'
    content = content + 'from: ' + name + '\n'
    content = content + 'date: ' + strftime("%Y-%m-%d %H:%M:%S", localtime()) + '\n\n'
    content = content + update.message.text
    content = content + '\n-------------------------'
    content = content + '\n\n\n\n'
    try:
        printer_output(content)
    except Exception as e:
        update.message.reply_text('Failed to send note: ' + str(e))
        return
    update.message.reply_text('Delivered')

if __name__ == '__main__':
    updater = Updater(TOKEN)
    dispatcher = updater.dispatcher
    start_handler = CommandHandler('start', start)
    dispatcher.add_handler(start_handler)
    dispatcher.add_handler(MessageHandler(~Filters.command, print_msg))

    updater.start_polling()
    updater.idle()
```

Due to network issues in China, the bot cannot directly connect to Telegram's API server, so a proxy should be used here. The most convenient one is `proxychains-ng`:

```
# RedHat based:
$ sudo yum install proxychains-ng

# Debian based:
$ sudo apt-get install proxychains-ng
```

Then modify the configuration file `/etc/proxychains.conf`, adding your proxy address and port in the ProxyList section. For example, socks5 usually uses port 1080 of localhost:

```
[ProxyList]
# add proxy here ...
socks5  127.0.0.1 1080
```

Finally, run the bot:

```
proxychains -q python3 bot.py
```

If everything goes smoothly, a printer that can pass notes should already be working.

= Summary and Advanced Usage

So far, the note-passing feature is still very limited, only able to print GBK-encoded character text. For more complex functions, you can look at python-escpos. Almost all POS printers on the market interact with computers using the ESC/POS protocol. Using the image printing function in the ESC/POS protocol, you can print barcodes, QR codes, and images.

For UTF-8 encoded text, if it contains characters such as Korean or emojis that do not belong to the GBK character set, it can also be indirectly implemented using the image printing function: render it as an image on the computer yourself first, and then print it.

]
)

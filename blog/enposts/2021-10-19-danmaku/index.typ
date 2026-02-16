// Developing a Danmaku Reader
#import "/template-en.typ":*

#doc-template(
title: "Developing a Danmaku Reader",
date: "October 19, 2021",
body: [

I recently have plans to become a transparent, silent-type vTuber. To increase the entertainment effect, I created a Danmaku (bullet chat) reader. Since I didn't want to spend too much time, I chose Python for a quick solution.

= How to Read Aloud

I directly used the built-in speech synthesis feature of the Windows operating system: #link("https://docs.microsoft.com/en-us/previous-versions/windows/desktop/ms723602(v=vs.85)", "SpVoice").

This interface can be called using #link("https://pypi.org/project/pywin32/", "PyWin32").

First, you need to install PyWin32:

```
pip3 install pywin32
```

Example code:

```
import win32com.client

speaker = win32com.client.Dispatch("SAPI.SpVoice")
speaker.Speak("Hello, world!")
```

= How to Get Danmaku

Twitch's chat system is quite interesting; they actually use an #link("https://dev.twitch.tv/docs/irc/guide#connecting-to-twitch-irc", "IRC interface") for their chatbot interface.

So, you can even use the `nc` command to operate it manually:

```
[mistivia@arch ~]$ nc irc.chat.twitch.tv 6667
< PASS oauth:<Twitch OAuth token>
< NICK <user>
> :tmi.twitch.tv 001 <user> :Welcome, GLHF!
> :tmi.twitch.tv 002 <user> :Your host is tmi.twitch.tv
> :tmi.twitch.tv 003 <user> :This server is rather new
> :tmi.twitch.tv 004 <user> :-
> :tmi.twitch.tv 375 <user> :-
> :tmi.twitch.tv 372 <user> :You are in a maze of twisty passages, all alike.
> :tmi.twitch.tv 376 <user> :>
JOIN #channel
```

Note the prompt after logging in:

```
You are in a maze of twitsy passages, all alike.
```

This is actually an Easter egg from the 1970s adventure game on the PDP-10 computer: #link("https://en.wikipedia.org/wiki/Colossal_Cave_Adventure#Maze_of_twisty_little_passages", "Colossal Cave Adventure"), commonly known as *Adventure*. This was the world's first interactive fiction, as well as the first adventure game and text adventure game.

This game later had a graphical adaptation on the Atari console, also called *Adventure*, which is considered the first game in history to contain an Easter egg (the one in *Ready Player One*).

Since IRC is a very old and mature text protocol, development only requires using some open-source IRC libraries in Python. Twitch officially provides an #link("https://github.com/twitchdev/chatbot-python-sample", "example of a chatbot implemented in Python 2"). It can be used in Python 3 with a few modifications.

It uses an #link("https://pypi.org/project/irc/", "IRC library for Python"), which needs to be installed beforehand:

```
pip3 install irc
```

Final code:

```
# Windows Only
# Dependencies: pip install pywin32 irc

import win32com.client
import irc.bot

# your username
username = "mistivia"
botname = "mybot"
# channel name, prepending '#' is a must
channel = "#mistivia"
# To get a token, visit: http://twitchapps.com/tmi/
token = "oauth:YOUR TOKEN HERE"

server = "irc.chat.twitch.tv"
port = 6667

speaker = win32com.client.Dispatch("SAPI.SpVoice")

class TwitchBot(irc.bot.SingleServerIRCBot):
    def __init__(self, username, client_id, token, channel):
        self.client_id = client_id
        self.token = token
        self.channel = channel

        print('Connecting to ' + server + ' on port ' + str(port) + '...')
        irc.bot.SingleServerIRCBot.__init__(
            self, [(server, port, token)], username, username)


    def on_welcome(self, c, e):
        print('Joining ' + self.channel)

        # You must request specific capabilities before you can use them
        c.join(self.channel)

    def on_pubmsg(self, c, e):
        self.on_msg(e.source.nick, e.arguments[0])

    def on_msg(self, nick, msg):
        print(nick + ": " + msg)
        speaker.Speak(nick + " says: " + msg)

if __name__ == "__main__":
    bot = TwitchBot(username,botname, token, channel)
    bot.start()
```

])

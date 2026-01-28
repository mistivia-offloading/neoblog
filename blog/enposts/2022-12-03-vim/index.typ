// Creating Text Processing Tools with Vim
#import "/template-en.typ":doc-template

#doc-template(
title: "Creating Text Processing Tools with Vim",
date: "December 3, 2022",
body: [

First, create a Vim script. For example, a script to automatically wrap text at column 70 is as follows:

```
:set tw=70
gggqG
:wq
```

Save it as `~/.vim/scripts/wrap`, and then you can process a file:

```
vim -s ~/.vim/scripts/wrap input.txt
```

If you want to use it with stdin and stdout so it can be used in a pipeline and called by other programs, you can wrap it with a bash script:

```
#!/bin/bash

BUF=/tmp/$(head -c 15 /dev/urandom | base32)
cat > $BUF
/usr/bin/vim -s ~/.vim/scripts/wrap $BUF 1>/dev/null 2>/dev/null
cat $BUF
rm $BUF
```

And just like that, a small tool is complete.

]
)
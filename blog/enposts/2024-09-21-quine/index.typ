// Writing a Quine the "Dumb Way"
#import "/template-en.typ":doc-template

#doc-template(
title: "Writing a Quine the \"Dumb Way\"",
date: "September 21, 2024",
body: [

#let wrap-anywhere(content) = {
  content.replace(regex("([^\n])"), (m) => m.text + "\u{200b}")
}
#show raw.where(block: true): it => {
  par(leading:0pt,spacing:0pt)[#text(size:0pt)[]]
  block(
    inset: (left: 24pt, top: 0em, bottom: 0em),
    width: 100%,
    text(wrap-anywhere(it.text))
  )
  par(leading:0pt,spacing:0pt)[#text(size:0pt)[]]
}

= What is a Quine?

A Quine is a type of program that outputs its own source code when executed. These programs are also known as "self-replicating programs" and possess a fascinating self-referential quality similar to biological organisms.

Here are two examples of quines that I copied from #link("https://en.wikipedia.org/wiki/Quine_%28computing%29")[Wikipedia].

Example 1: Python

```
c = 'c = %r; print(c %% c)'; print(c % c)
```

Example 2: Java

```
public class Quine
{
  public static void main(String[] args)
  {
    char q = 34;      // Quotation mark character
    String[] l = {    // Array of source code
    "public class Quine",
    "{",
    "  public static void main(String[] args)",
    "  {",
    "    char q = 34;      // Quotation mark character",
    "    String[] l = {    // Array of source code",
    "    ",
    "    };",
    "    for (int i = 0; i < 6; i++)           // Print opening code",
    "        System.out.println(l[i]);",
    "    for (int i = 0; i < l.length; i++)    // Print string array",
    "        System.out.println(l[6] + q + l[i] + q + ',');",
    "    for (int i = 7; i < l.length; i++)    // Print this code",
    "        System.out.println(l[i]);",
    "  }",
    "}",
    };
    for (int i = 0; i < 6; i++)           // Print opening code
        System.out.println(l[i]);
    for (int i = 0; i < l.length; i++)    // Print string array
        System.out.println(l[6] + q + l[i] + q + ',');
    for (int i = 7; i < l.length; i++)    // Print this code
        System.out.println(l[i]);
  }
}
```

However, in these two examples, the code is not very easy to understand. If I wanted to write a quine in a third language, such as C++ or JavaScript, I would need to rethink the entire logic.

Therefore, I wanted to find a general method to write a quine in the most intuitive and easiest way possible. Although this type of quine might not be the shortest or most efficient, it is the most straightforward and easiest to adapt to other languages.

= The Patterns of a Quine

Looking at the two quines in the previous section, although they appear quite different, they can generally be summarized in the following steps:

1. A header, which may contain some imports or class definitions;
2. A string that acts somewhat like genetic material, which I will call *DNA*. Its content should include the program code before this string and the program code after it;
3. A footer:
   1. Extract the header from the *DNA* string and print it;
   2. Print the *DNA* string itself;
   3. Extract the footer from the *DNA* string and print it.

Although it sounds simple, in most common programming languages, expressing strings requires additional escaping for characters like newlines and quotation marks. For example, a newline must be written as `\n`, and quotation marks must be preceded by a backslash. This content brings unnecessary trouble, which is also why the code above is hard to read.

However, these escape characters are essentially a form of **encoding**. So, my idea is to directly encode the *DNA* string into the simplest hexadecimal form and then decode it when it needs to be printed.

This way, no weird hacks are needed.

Furthermore, it doesn't necessarily have to be hexadecimal encoding; base64, base32, or even using base letters like real DNA would work.

= A Handy Tool

To encode a string into hexadecimal, I wrote a small tool in Python that reads a string and outputs its hexadecimal form:

```
import sys

s = sys.stdin.read()
if s[-1] == '\n':
  s = s[:-1]
print(s.encode('utf-8').hex())
```

Save the code above as `hexencode.py`, and then you can use it in the Shell like this:

```
cat input.txt | python3 hexencode.py
```

= Starting to Write Code

Python is relatively simple to write, so let's start with Python.

First, define the *DNA* string. Since we don't know the content of "DNA" yet, we'll use emoji symbols as placeholders. Since this string contains two parts: the header and the footer, let's assume the header is a tiger and the footer is a snake:

```
dna = '🐱,🐍'
```

Then, extract the header and footer:

```
head, tail = dna.split(',')
```

Since we plan to use hexadecimal encoding, we need to decode the header and footer from hexadecimal back to their original form:

```
head = bytes.fromhex(head).decode('utf-8')
tail = bytes.fromhex(tail).decode('utf-8')
```

Finally, we concatenate the header, DNA, and footer, and output them together:

```
print(head + dna + tail)
```

The current program looks like this:

```
dna = '🐱,🐍'
head, tail = dna.split(',')
head = bytes.fromhex(head).decode('utf-8')
tail = bytes.fromhex(tail).decode('utf-8')
print(head + dna + tail)
```

The part before the tiger 🐱 header is:

```
dna = '\n```

Encoding this using our handy tool gives:

`646e61203d2027`

Replace 🐱 with this string.

Next, the part after the snake 🐍 footer is:

```
'\nhead, tail = dna.split(',')\nhead = bytes.fromhex(head).decode('utf-8')\ntail = bytes.fromhex(tail).decode('utf-8')\nprint(head + dna + tail)
```

Encoding this using our handy tool gives:

```
270a686561642c207461696c203d20646e612e73706c697428272c27290a68656164203d2062797465732e66726f6d6865782868656164292e6465636f646528277574662d3827290a7461696c203d2062797465732e66726f6d686578287461696c292e6465636f646528277574662d3827290a7072696e742868656164202b20646e61202b207461696c29
```

Replace 🐍 with this string.

Finally, we get the following code:

```
dna = '646e61203d2027,270a686561642c207461696c203d20646e612e73706c697428272c27290a68656164203d2062797465732e66726f6d6865782868656164292e6465636f646528277574662d3827290a7461696c203d2062797465732e66726f6d686578287461696c292e6465636f646528277574662d3827290a7072696e742868656164202b20646e61202b207461696c29'
head, tail = dna.split(',')
head = bytes.fromhex(head).decode('utf-8')
tail = bytes.fromhex(tail).decode('utf-8')
print(head + dna + tail)
```

At this point, a quine is complete. Give it a try!

= Extending to Other Languages

Let's use C++ as an example:

First, write a similar template:

```
#include <iostream>
#include <string>

void split(std::string input, std::string &first, std::string &second);
std::string hex_decode(std::string hex);

int main() {
  std::string dna = "🐱,🐍";
  
  std::string head, tail;
  split(dna, head, tail);
  head = hex_decode(head);
  tail = hex_decode(tail);
  
  std::cout << head << dna << tail << std::endl;
}

// The troublesome part is that the C++ standard library does not provide split and hexadecimal decoding functions.
// I'm too lazy to write them myself, so I'll just have AI generate them:

void split(std::string input, std::string &first, std::string &second) {
    size_t commaPos = input.find(',');
    if (commaPos != std::string::npos) {
        first = input.substr(0, commaPos);
        second = input.substr(commaPos + 1);
    } else {
        first = input;
        second = "";
    }
}

std::string hex_decode(std::string input) {
    std::string output;
    output.reserve(input.size() / 2);
    for (size_t i = 0; i < input.size(); i += 2) {
        std::string byteString = input.substr(i, 2);
        char byte = static_cast<char>(std::strtol(byteString.c_str(), nullptr, 16));
        output.push_back(byte);
    }
    return output;
}
```

Then, encode the program text before 🐱 and after 🐍 into hexadecimal using our tool and replace them:

```
#include <iostream>
#include <string>

void split(std::string input, std::string &first, std::string &second);
std::string hex_decode(std::string hex);

int main() {
  std::string dna = "23696e636c756465203c696f73747265616d3e0a23696e636c756465203c737472696e673e0a0a766f69642073706c6974287374643a3a737472696e6720696e7075742c207374643a3a737472696e67202666697273742c207374643a3a737472696e6720267365636f6e64293b0a7374643a3a737472696e67206865785f6465636f6465287374643a3a737472696e6720686578293b0a0a696e74206d61696e2829207b0a20207374643a3a737472696e6720646e61203d2022,223b0a20200a20207374643a3a737472696e6720686561642c207461696c3b0a202073706c697428646e612c20686561642c207461696c293b0a202068656164203d206865785f6465636f64652868656164293b0a20207461696c203d206865785f6465636f6465287461696c293b0a20200a20207374643a3a636f7574203c3c2068656164203c3c20646e61203c3c207461696c203c3c207374643a3a656e646c3b0a7d0a0a2f2f20e9babbe783a6e79a84e59cb0e696b9e698af432b2be6a087e58786e5ba93e9878ce99da2e4b88de68f90e4be9be58886e589b2e5928c3136e8bf9be588b6e8a7a3e7a081e587bde695b00a2f2f20e68891e4b99fe68792e5be97e58699e4ba86efbc8ce79bb4e68ea54149e7949fe68890e4b880e4b880e4b88b3a0a0a766f69642073706c6974287374643a3a737472696e6720696e7075742c207374643a3a737472696e67202666697273742c207374643a3a737472696e6720267365636f6e6429207b0a2020202073697a655f7420636f6d6d61506f73203d20696e7075742e66696e6428272c27293b0a2020202069662028636f6d6d61506f7320213d207374643a3a737472696e673a3a6e706f7329207b0a20202020202020206669727374203d20696e7075742e73756273747228302c20636f6d6d61506f73293b0a20202020202020207365636f6e64203d20696e7075742e73756273747228636f6d6d61506f73202b2031293b0a202020207d20656c7365207b0a20202020202020206669727374203d20696e7075743b0a20202020202020207365636f6e64203d2022223b0a202020207d0a7d0a0a7374643a3a737472696e67206865785f6465636f6465287374643a3a737472696e6720696e70757429207b0a202020207374643a3a737472696e67206f75747075743b0a202020206f75747075742e7265736572766528696e7075742e73697a652829202f2032293b0a20202020666f72202873697a655f742069203d20303b2069203c20696e7075742e73697a6528293b2069202b3d203229207b0a20202020202020207374643a3a737472696e672062797465537472696e67203d20696e7075742e73756273747228692c2032293b0a2020202020202020636861722062797465203d207374617469635f636173743c636861723e287374643a3a737472746f6c2862797465537472696e67202e635f73747228292c206e756c6c7074722c20313629293b0a20202020202020206f75747075742e707573685f6261636b2862797465293b0a202020207d0a2020202072657475726e206f75747075743b0a7d"
  
  std::string head, tail;
  split(dna, head, tail);
  head = hex_decode(head);
  tail = hex_decode(tail);
  
  std::cout << head << dna << tail << std::endl;
}

// The troublesome part is that the C++ standard library does not provide split and hexadecimal decoding functions.
// I'm too lazy to write them myself, so I'll just have AI generate them:

void split(std::string input, std::string &first, std::string &second) {
    size_t commaPos = input.find(',');
    if (commaPos != std::string::npos) {
        first = input.substr(0, commaPos);
        second = input.substr(commaPos + 1);
    } else {
        first = input;
        second = "";
    }
}

std::string hex_decode(std::string input) {
    std::string output;
    output.reserve(input.size() / 2);
    for (size_t i = 0; i < input.size(); i += 2) {
        std::string byteString = input.substr(i, 2);
        char byte = static_cast<char>(std::strtol(byteString.c_str(), nullptr, 16));
        output.push_back(byte);
    }
    return output;
}
```

Save this C++ source code as `quine.cpp`, and then use the following command to verify that its output is identical to the original source code:

```
g++ quine.cpp && ./a.out | diff quine.cpp -
```

= Multilingual Quines

There is another type of quine where a program written in language A outputs the source code of a program in language B, which in turn outputs the original source code in language A, forming a cycle from A to B back to A. This process can even involve more languages, such as a cycle from A to B to C to D to E and back to A.

On GitHub, #link("https://github.com/mame/quine-relay")[there is a project that constructed a cycle involving over 100 languages].

After using this "dumb way" of hexadecimal encoding, we no longer need to worry about escape characters, making it easy to construct cycles of any number of languages.

Next, we'll combine the Python and C++ examples above to construct a C++ program that outputs a Python program, which in turn outputs the original C++ program.

First, write the Python template, same as before:

```
dna = '🐱,🐍'
head, tail = dna.split(',')
head = bytes.fromhex(head).decode('utf-8')
tail = bytes.fromhex(tail).decode('utf-8')
print(head + dna + tail)
```

Then, write a C++ program to output the above template:

```
#include <iostream>
#include <string>

std::string py =
    "dna = '🐱,🐍'\n"
    "head, tail = dna.split(',')\n"
    "head = bytes.fromhex(head).decode('utf-8')\n"
    "tail = bytes.fromhex(tail).decode('utf-8')\n"
    "print(head + dna + tail)\n";

int main() {
    std::cout << py;
    return 0;
}
```

Then, encode the program text before 🐱 and after 🐍 in this C++ code into hexadecimal using our tool and replace them:

```
#include <iostream>
#include <string>

std::string py =
    "dna = '23696e636c756465203c696f73747265616d3e0a23696e636c756465203c737472696e673e0a0a7374643a3a737472696e67207079203d0a2020202022646e61203d2027,275c6e220a2020202022686561642c207461696c203d20646e612e73706c697428272c27295c6e220a202020202268656164203d2062797465732e66726f6d6865782868656164292e6465636f646528277574662d3827295c6e220a20202020227461696c203d2062797465732e66726f6d686578287461696c292e6465636f646528277574662d3827295c6e220a20202020227072696e742868656164202b20646e61202b207461696c295c6e223b0a0a696e74206d61696e2829207b0a202020207374643a3a636f7574203c3c2070793b0a2020202072657475726e20303b0a7d"
```

Save this code as `quine.cpp` and verify the results:

```
g++ quine.cpp
./a.out > quine.py
python3 quine.py > quine2.cpp
diff quine.cpp quine2.cpp
```

Mission accomplished.

]
)

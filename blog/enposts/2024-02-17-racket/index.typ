// Successfully Getting Started with Racket
#import "/template-en.typ":*
#doc-template(
title: "Successfully Getting Started with Racket",
date: "February 17, 2024",
body: [

During the Spring Festival, I had nothing to do at home, so I used Racket to solve several problems on #link("https://adventofcode.com/2023")[Advent of Code 2023]. My previous attempts at learning Scheme-like languages were not very smooth and I faced many setbacks. However, this time it went very smoothly. I suddenly felt comfortable writing code, and I even learned how to write hygienic macros. Maybe I suddenly had an epiphany.

Initially, I wanted to use C to solve these problems. But sure enough, as the problems became increasingly complex, using C to write these things started to feel a bit taxing on my sanity, especially string processing, which is what C is least good at.

Compared to C, Racket is much more relaxed. At least you don't have to spend half a day flipping through documentation for a function that converts a string to a number. At the same time, the simplicity of Racket, or Scheme, is comparable to C. In terms of the number of pages in the standard documentation, ISO C is about 200 pages, while R5RS is only over 50 pages. Even the R6RS, which is widely criticized for being "too complex," is only over 100 pages. Racket is a "batteries-included" variant of Scheme with very powerful features, but the core of the language still maintains the tradition of Scheme and is very refined. I have a R5RS cheat sheet on my desk that is only half a page long, which is enough to handle most daily functional needs.

"The Zen of Python" mentions:

#myquote([
  Explicit is better than implicit. 
  Simple is better than complex.
])

However, it is clear that today's Python has not achieved this; instead, it has gone in the opposite direction. I have never understood Python's Metaclass, and there are various subtle pitfalls in OOP that make me tremble with fear. Coupled with new features like gradual typing and await/async, I no longer dare to say I know how to write Python. JavaScript has similar problems. As for C++, let's not even mention it. Racket originated in academia and also pursues new functions and features, but the core part of the language is stable. When using Racket, you can choose to use only the core part similar to R5RS, or you can use the huge standard library and complex features like contracts and Typed Racket.

It's not that I can't adapt to complex syntax. I even used to be very interested in being a C++ language lawyer. However, these things are gradually forgotten if they are not used for a long time, and it takes a lot of effort to pick them up again, like Sisyphus. Life is short, and now I am more unwilling to waste my precious time on these obscure and useless details.

The performance of Racket is also good. Although it naturally cannot compare with the likes of C/C++, Rust, it is roughly in the same tier as Java and Node.js (and sometimes slightly slower), but it is much stronger than scripting languages like Python and Ruby. This probably has something to do with the Racket on Chez Scheme work in recent years.

The last advantage is probably that Racket is very suitable for developing "cold-blooded software." This concept was proposed in #link("https://dubroy.com/blog/cold-blooded-software/")[this blog]. Here, "cold-blooded" does not mean the cold-bloodedness of a "cold-blooded killer," but the cold-bloodedness of a "cold-blooded animal," which roughly means it can hibernate and still be picked up many years later. It won't be like after a few years, the API and SDK have changed drastically, and even the development environment cannot be configured (this is very common in languages like Python and JavaScript; the messy dependencies and build systems of C++ also lead to similar problems). But I have reason to believe that Racket is unlikely to have similar phenomena because the language core is very refined. I remember that I once downloaded the code for a Scheme interpreter from the 1980s. At that time, there was not even an ISO C standard, but this code could be successfully compiled and executed on a modern Linux system with minor modifications, which left a deep impression on me.

These are my thoughts on successfully getting started with Racket recently. I have some side project ideas recently and plan to try them with Racket.

])

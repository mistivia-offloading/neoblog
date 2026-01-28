// Evil Scheme
#import "/template-en.typ":doc-template

#doc-template(
title: "Evil Scheme",
date: "December 13, 2022",
body: [

Because Scheme, like other languages in the Lisp family, is extremely flexible, you can add many strange things to the language. You can even write Scheme code in an imperative way, much like Python, if you wish.

The code in this article is written for GNU Guile and TinyScheme, both of which support old-style Lisp macros. These macros are more common in Common Lisp, are not hygienic, and do not belong to any Scheme standard. However, most interpreters and compilers support them.

For example, if you want to run the code in Racket, you just need to add the following syntax at the beginning:

```
#lang racket

(define-syntax define-macro
  (lambda (x)
    (syntax-case x ()
      ((_ (macro . args) body ...)
       #'(define-macro macro (lambda args body ...)))
      ((_ macro transformer)
       #'(define-syntax macro
           (lambda (y)
             (syntax-case y ()
               ((_ . args)
                (let ((v (syntax->datum #'args)))
                  (datum->syntax y (apply transformer v)))))))))))
```

= hello, world

Python code:

```
print("hello, world")
```

Function definition:

```
(define println
    (lambda x
      (apply display x)
      (newline)))
```

Final effect:

```
(println "hello world")
```

= Def

Python code:

```
def is_even(x):
    if x % 2 == 0:
        return True
    return False
```

Macro definition:

```
(define-macro (def form . body)
    `(define ,form
         (call/cc (lambda (return)
            ,@body))))
```

Final effect:

```
(def (is-even x)
    (cond ((= 0 (modulo x 2))
        (return #t)))
    (return #f))
```


= While

Python code:

```
i = 0
while True:
    i = i + 1
    if x % 2 == 0:
        continue
    print(i)
    if i > 10:
        break
```


Macro definition:

```
(define-macro (while condition . body)
    (let ((loop (gensym)))
        `(call/cc (lambda (break)
            (letrec ((,loop (lambda ()
                (cond (,condition
                    (call/cc (lambda (continue)
                            ,@body))
                    (,loop))))))
                (,loop))))))
```


Final effect:

```
(let ((i 0))
(while #t
    (set! i (+ i 1))
    (cond ((= (modulo i 2) 0)
         (continue)))
    (cond ((> i 10)
        (break)))
    (println i)))
```


= For

Python code:

```
for i in range(0, 10):
    print(i)
```


Macro and utility function definitions:

```
(define (iter-get iter)
    (cond ((list? iter)
        (car iter))
    (else
        (iter 'get))))

(define (iter-next iter)
    (cond ((list? iter)
        (cdr iter))
    (else
        (iter 'next))))

(define (range start end)
    (lambda (method)
        (cond ((eq? 'get method)
            (if (>= start end)
                '()
                start))
        ((eq? 'next method)
            (range (+ 1 start) end)))))

(define-macro (for i range . body)
    (let ((loop (gensym))
          (iter (gensym)))
    `(call/cc (lambda (break)
        (letrec
            ((,loop (lambda (,iter)
                (if (eq? (iter-get ,iter) '())
                    '()
                    (let ((,i (iter-get ,iter)))
                          (call/cc (lambda (continue)
                             ,@body))
                          (,loop (iter-next ,iter)))))))
            (,loop ,range))))))
```


Final effect:

```
(for i (range 0 10)
    (println i))
```


= Goto

Let's skip this one!

= Fizz Buzz!

Python implementation:

```
for i in range(35):
    if i % 15 == 0:
        print("FizzBuzz")
        continue
    if i % 3 == 0:
        print("Fizz")
        continue
    if i % 5 == 0:
        print("Buzz")
        continue
    print(i)
```

Using Scheme, with the macros above, it can correspond almost one-to-one:

```
(for i (range 1 35)
    (cond ((= 0 (modulo i 15))
        (println "FizzBuzz")
        (continue)))
    (cond ((= 0 (modulo i 3))
        (println "Fizz")
        (continue)))
    (cond ((= 0 (modulo i 5))
        (println "Buzz")
        (continue)))
    (println i))
```

]
)
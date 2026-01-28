// From Hello World to IO Monad
#import "/template-en.typ":doc-template

#doc-template(
title: "From Hello World to IO Monad",
date: "March 28, 2025",
body: [

This is a piece of unremarkable Python code:

```
def main():
    x = input()
    y = input()
    print(x + y)

main()
```

The main function of this code is to output "Hello World".

Step 1: Input "Hello":

```
hello
```

Step 2: Input " World":

```
hello
    world
```

Finally press enter, and the third step will result in:

```
hello world
```

If you have encountered some asynchronous programming, you will notice that `input` is an I/O operation. If you want to perform I/O efficiently, you often need to do asynchronous I/O.

In the ancient times before async/await was born, if we wanted to make a program asynchronous, we had to write it in the form of callback functions.

Of course, `input` here is not an asynchronous I/O function, but that doesn't prevent us from changing this program to the form of callback functions, just for fun.

We split `main` into three functions, and each function will call the next step at the end:

```
def main():
    step1()

def step1():
    x = input()
    step2(x)

def step2(x):
    y = input()
    step3(x, y)

def step3(x, y):
    print(x + y)
```

This code has the same function as the original version.

Then make the code more compact:

```
def main():
    step1()

def step1():
    step2(input())

def step2(x):
    step3(x, input())

def step3(x, y):
    print(x + y)
```

Python allows defining functions inside functions, like this:

```
def f1():
    def f2():
        do_something()
    f2()
```

We use this way to pile all functions together, and each step function is defined in the previous step, so there is still only one `main` function:

```
def main():
    def step1():
        def step2(x):
            def step3(x, y):
                print(x + y)
            step3(x, input())
        step2(input());
    step1()
```

Python has a feature called "closure". Because `step3` is defined inside `step2`, `step3` can directly access the parameter `x` of `step2` without needing to pass it in specifically. So we can simplify it slightly:

```
def main():
    def step1():
        def step2(x):
            def step3(y):
                print(x + y)
            step3(input())
        step2(input());
    step1()
```

In the above code, the structure of `step1` and `step2` is very similar, both like this:

```
def step(...):
    def next_step(...) 
        ...
    next_step(input())
```

Note the last line `next_step(input())`, its function is to call `input`, get the input result, and pass it as a parameter to the next step. Since the `input()` step is fixed and only the next function changes, we might as well take the next function as a parameter and define a new function:

```
def input_and_do(next_step):
    next_step(input())
```

This function has the same effect as `next_step(input())`.

Then, rewrite the `main` function using this newly defined `input_and_do`:

```
def main():
    def step2(x):
        def step3(y):
            print(x + y)
        input_and_do(step3)
    input_and_do(step2)
```

There is a feature in Python called lambda expressions. A function that originally required two lines to define:

```
def fn(x):
    return meow(x)
```

only needs one line with lambda:

```
lambda x: meow(x)
```

So, `step3` can be written as:

```
lambda y: print(x + y)
```

`step2` can be written as:

```
lambda x: input_and_do(step3)
```

Substituting `step3` in, `step2` becomes:

```
lambda x: input_and_do(lambda y: print(x + y))
```

In this way, `main` can be rewritten in one line:

```
def main():
    input_and_do(lambda x: input_and_do(lambda y: print(x + y)))
```

However, it looks a bit messy, so do some formatting. We get the final Python program, which looks very abstract (in a fun way):

```
def input_and_do(next_step):
    next_step(input())

def main():
    input_and_do(lambda x: ( \
        input_and_do(lambda y: \
            print(x + y))))
```

Since "IO monad" is written in the title, let's start with Haskell. We try to rewrite the above Python code in Haskell. Since it has been written in a way that is all lambdas, we can naturally replicate this code pixel-by-pixel.

However, the function names in the Haskell standard library are slightly different: `input` corresponds to `getLine`, and `print` corresponds to `putStrLn`:

```
inputAndDo nextStep = nextStep getLine    

main :: IO ()
main = inputAndDo(\x ->
            inputAndDo(\y ->
                putStrLn (x ++ y)))
```

If nothing goes wrong, this code should run.

But something went wrong:

```
• Couldn't match expected type: [Char]
                with actual type: IO String
• In the first argument of ‘(++)’, namely ‘x’
    In the first argument of ‘putStrLn’, namely ‘(x ++ y)’
    In the expression: putStrLn (x ++ y)
```

We originally expected the types of `x` and `y` to be `String`, but they actually became `IO String`. The problem lies in `getLine`. `getLine` does not return a simple `String`, but an `IO String`:

```
ghci> :t getLine
getLine :: IO String
```

The return value of `getLine` (type `IO String`) was passed as `x` and `y` to `putStrLn`, but the argument type expected by `putStrLn` is `String`, so an error occurred.

The `String` we want is wrapped by the IO monad. We need to "unwrap" it, changing `IO String` to `String`.

To solve this problem, first see what `IO String` is. `IO` is a monad, and the definition of a monad is:

```
class Monad m where
    (>>=)  :: m a -> (a -> m b) -> m b
    ...
```

Specifically for `IO` and `IO String`, that is to say, the type of the `(>>=)` operator becomes:

```
IO String -> (String -> IO b) -> IO b
```

A function that only accepts `String` as a parameter can be passed `IO String` to "unwrap" it and get the `String` inside, as long as `(>>=)` is used.

But power often comes with a price. If a function wants to use `(>>=)` to unwrap the seal of the IO monad, then the return value of this function must also be an IO monad.

We choose to accept this price and modify `inputAndDo`:

```
inputAndDo nextStep = (>>=) getLine nextStep
```

Then change it to infix form:

```
inputAndDo nextStep = getLine >>= nextStep
```

The final Haskell code is as follows:

```
inputAndDo nextStep = (getLine >>= nextStep)

main :: IO ()
main = inputAndDo(\x ->
            inputAndDo(\y ->
                putStrLn (x ++ y)))
```

This code works!

Since `inputAndDo nextStep` is equivalent to `getLine >>= nextStep`, we can actually directly change `inputAndDo` to `getLine >>=`:

```
main :: IO ()
main = getLine >>= (\x->
            getLine >>= (\y ->
                putStrLn (x ++ y)))
```

The effect is the same. However, this code, like the abstract version of the Python code above, still looks distressing.

Fortunately, there is a syntactic sugar in Haskell called "do notation," which can turn an expression like this:

```
uwu >>= (\x -> ...)
```

into this:

```
do
    x <- uwu
    ...
```

This looks much better.

So we change it like this, starting with the first step:

```
main :: IO ()
main = do
    x <- getLine
    getLine >>= (\y ->
                    putStrLn (x ++ y))
```

The second step is also in the same form, so we can continue the overhaul:

```
main :: IO ()
main = do
    x <- getLine
    y <- getLine
    putStrLn (x ++ y)
```

The overhaul is complete. Let's compare it with the Python code at the beginning:

```
def main():
    x = input()
    y = input()
    print(x + y)
```

EXACTLY THE SAME.

In this way, we have returned to the original starting point. This journey ends here.

])


// Type-level Programming: A Most Trivial Example
#import "/template-en.typ": doc-template

#doc-template(
title: "Type-level Programming: A Most Trivial Example",
date: "May 17, 2025",
body: [

This article will use Haskell.

First, enable some extensions:

```
{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds#-}
{-# LANGUAGE TypeOperators #-}
{-# OPTIONS_GHC -Werror=incomplete-patterns #-}

import Data.Type.Equality
```

= Zero and One

Everything in a computer is "zero" and "one":

```
data Bit = Zero | One
```

Create a type for each of the two values in the `Bit` type, "zero" and "one," which are singleton types:

```
-- Prefix S is an abbreviation for Singleton
data SBit :: Bit -> * where
    SZero :: SBit 'Zero
    SOne  :: SBit 'One
```

= NAND Gate

All boolean circuits can be completed with NAND gates, but we must first define the NAND gate:

```
type family Nand (a :: Bit) (b :: Bit) :: Bit where
    Nand 'One 'One = 'Zero
    Nand _ _ = 'One
```

`type family` gives the "definition," which can also be called a "specification" (Spec). Whether it is proof or checking, the program must comply with the standard here.

Then we can implement it:

```
nandGate :: SBit a -> SBit b -> SBit (Nand a b)
nandGate SOne SOne = SZero
nandGate SZero _ = SOne
nandGate _ SZero = SOne
```

= NOT Gate

Zero becomes one, and one becomes zero; this is the NOT gate. Therefore, give the definition:

```
type family Not (a :: Bit) :: Bit where
    Not 'One = 'Zero
    Not 'Zero = 'One
```

A NOT gate can be implemented using a NAND gate:

```
notGateImpl x = nandGate x x
```

Submit the implementation to the compiler:

```
notGate :: SBit a -> SBit (Not a)
notGate = notGateImpl
```

Rejected by the compiler:

```
Couldn't match type: Nand a a
            with: Not a
Expected: SBit a -> SBit (Not a)
Actual: SBit a -> SBit (Nand a a)
```

`notGateImpl` returns `SBit (Nand a a)`, while what `notGate` expects is `SBit (Not a)`. We need to prove that `SBit (Not a)` and `SBit (Nand a a)` are the same thing. In this way, conversion can be achieved.

There are two ideas here. The first is to use pure force to crush it, proving by brute-force enumeration that this thing is absolutely true:

```
notGateProof :: SBit a -> SBit (Nand a a) :~: SBit (Not a)
notGateProof SOne = Refl
notGateProof SZero = Refl
```

Then use this proof to achieve safe type conversion:

```
notGate :: SBit a -> SBit (Not a)
notGate x = castWith (notGateProof x) (notGateImpl x)
```

The NOT gate is complete.

The second idea is to settle for the second best and only add a type constraint:

```
notGate :: (SBit (Nand a a) ~ SBit (Not a)) => SBit a -> SBit (Not a)
notGate x = nandGate x x
```

This also passes compilation, and the code is relatively simple.

However, this is more like a "static check." For example, if we deliberately write a wrong implementation:

```
notGate :: (SBit 'Zero ~ SBit (Not a)) => SBit a -> SBit (Not a)
notGate x = SZero
```

Obviously, `SBit 'Zero` and `SBit (Not a)` are not equivalent when `a` is `'Zero`, but it still passes compilation.

If a `notGate` call where `x` is `SOne` appears in the program:

```
zero = notGate SOne
```

Because the condition happens to be met, it still passes compilation.

Only when a `notGate` call where `x` is `SZero` appears in the program:

```
one = notGate SZero
```

will the problem be found in type checking. At this time, the compiler will report an error:

```
• Couldn't match type ‘'Zero’ with ‘'One’
    arising from a use of ‘notGate’
• In the expression: notGate SZero
    In an equation for ‘one’: one = notGate SZero 
```

Since the second method is simpler, it will not be repeated later, and only the first one will be introduced. From a practical point of view, proofs for the first method are often difficult to give, and most of the time "static checks" like the second method are enough.

= AND Gate

What is an AND gate? One and one makes one, and the rest are zero:

```
type family And (a :: Bit) (b :: Bit) :: Bit where
    And 'One 'One = 'One
    And _ _ = 'Zero
```

A NAND gate plus a NOT gate is an AND gate:

```
andGateImpl a b = notGate $ nandGate a b
```

Use enumeration to brute-force proof:

```
andGateProof :: SBit a -> SBit b -> SBit (Not (Nand a b)) :~: SBit (And a b)
andGateProof SZero SOne = Refl
andGateProof SZero SZero = Refl
andGateProof SOne SOne = Refl
andGateProof SOne SZero = Refl
```

Submit to the compiler:

```
andGate :: SBit a -> SBit b -> SBit (And a b)
andGate a b = castWith (andGateProof a b) (andGateImpl a b)
```

The AND gate is complete.

= OR Gate

As usual, first give the definition: zero and zero make zero, and the rest are one:

```
type family Or (a :: Bit) (b :: Bit) :: Bit where
    Or 'Zero 'Zero = 'Zero
    Or _ _ = 'One
```

Try a fancy implementation method. Use De Morgan's laws to combine AND gates and NOT gates into OR gates:

```
orGateImpl a b = notGate (andGate (notGate a) (notGate b))
```

Continue with brute-force enumeration to prove I'm right:

```
orGateProof :: SBit a -> SBit b
    -> SBit(Not (And (Not a) (Not b))) :~: SBit (Or a b)
orGateProof SZero SZero = Refl
orGateProof SZero SOne = Refl
orGateProof SOne SZero = Refl
orGateProof SOne SOne = Refl
```

The compiler accepts it:

```
orGate :: SBit a -> SBit b -> SBit (Or a b)
orGate a b = castWith (orGateProof a b) (orGateImpl a b)
```

= Conclusion

This is a very trivial example, but it uses quite a few language features, which can be considered a summary of my recent learning. However, if I want to implement non-trivial examples, I often need to use some very complex and ugly Template Haskell libraries, which I don't really want to touch. So I'm planning to look into Lean 4 later.

])

// Using Haskell Like Rust
#import "/template-en.typ": doc-template

#doc-template(
title: "Using Haskell Like Rust",
date: "May 31, 2025",
body: [

= Introduction

In the field of systems programming, memory safety has always been a nightmare for C/C++ programmers. A simple `malloc` or `free` can plant hidden dangers that lead to program crashes, data corruption, or even security vulnerabilities. Today, we will explore how to use Haskell to tame these memory monsters, even achieving memory safety guarantees similar to Rust.

Let's start with some not-so-safe C code. Below are three functions: creating a matrix, filling a matrix with random floating-point numbers, and matrix multiplication. Because the matrix is created with the `malloc` function, to destroy the matrix, simply use `free`.

```
#include <stdlib.h>
#include <time.h>
#include <openblas/cblas.h>

#define N 1000

double* new_matrix() {
    double* mat = (double*)malloc(N * N * sizeof(double));
    return mat;
}

void fill_matrix(double* mat) {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            mat[i*N + j] = (double)rand() / RAND_MAX;
        }
    }
}

// Calculate c = a * b
void mat_mul(double* c, double* a, double* b) {
    cblas_dgemm(
        CblasRowMajor,
        CblasNoTrans,
        CblasNoTrans,
        N, N, N, 1.0,
        a, N, b, N, 1.0, c, N);
}
```

Then we write a `main` function:

```
int main() {
    double *a, *b, *c;

    srand(time(NULL));

    a = new_matrix();
    b = new_matrix();
    c = new_matrix();

    fill_matrix(a);
    fill_matrix(b);

    mat_mul(c, a, b);

    free(a);
    free(b);
    free(c);

    return 0;
}
```

Although this is a very simple example, because unsafe C language is used here, there are countless ways to crash the program.

For example, *double free*:

```
free(a);
free(a);
```

Or, *use-after-free*:

```
free(a);
fill_matrix(a);
```

Or *memory leaks* due to forgetting to free, and so on.

= Haskell FFI

Through Haskell's FFI (Foreign Function Interface), we can call these functions in Haskell.

First, enable the FFI extension:

```
{-# LANGUAGE ForeignFunctionInterface #-}
```

Import some necessary modules:

```
import Foreign.Ptr (Ptr)
import Foreign.C.Types (CDouble)
import Foreign.Marshal.Alloc (free)
```

Define FFI functions:

```
foreign import ccall "new_matrix"
    cNewMatrix :: IO (Ptr CDouble)

foreign import ccall "fill_matrix"
    cFillMatrix :: Ptr CDouble -> IO ()

foreign import ccall "mat_mul"
    cMatMul :: Ptr CDouble -> Ptr CDouble -> Ptr CDouble -> IO ()
```

Then you can call these functions:

```
main = do
    a <- cNewMatrix
    b <- cNewMatrix
    c <- cNewMatrix

    cFillMatrix a
    cFillMatrix b

    cMatMul c a b

    free a
    free b
    free c

    return ()
```

The `main` function here corresponds almost line-by-line to the version in C. However, the same security issues in C will also follow. All the C-related security issues mentioned above will occur here.

But, unlike C, this time we can solve this problem.

= Safe Pointers

Haskell's `Foreign.ForeignPtr` can provide a mechanism similar to RAII to avoid most memory safety issues.

Specifically for the above example, first, import some library functions:

```
import Foreign.ForeignPtr
```

Then change the pointer definition from a bare pointer to a safe `ForeignPtr`:

```
a <- cNewMatrix >>= newForeignPtr free
b <- cNewMatrix >>= newForeignPtr free
c <- cNewMatrix >>= newForeignPtr free
```

When using them, use `withForeignPtr` to create a scope, ensuring safe use within that scope. The complete code is as follows:

```
main = do
    a <- cNewMatrix >>= newForeignPtr finalizerFree
    b <- cNewMatrix >>= newForeignPtr finalizerFree
    c <- cNewMatrix >>= newForeignPtr finalizerFree
    withForeignPtr a $ \a ->
    withForeignPtr b $ \b ->
        withForeignPtr c $ \c -> do
        cFillMatrix a
        cFillMatrix b
        cMatMul c a b
```

In this way, we don't have to worry about memory safety.

= Linear Types

But the above method still has limitations; the lifecycle and ownership management it can achieve are very coarse.

For example, we cannot achieve the lifecycles of two objects that only partially overlap, like this:

```
a <- cNewMatrix
-- ..
b <- cNewMatrix
free a
-- ...
free b
```

Nor can we perform operations like this:

```
a <- cNewMatrix
if foo then
    free a 
else
    sendToAnotherThread a
```

If you want fine-grained lifecycle control, you need the latest and coolest linear type extension:

```
{-# LANGUAGE LinearTypes #-}
{-# LANGUAGE QualifiedDo #-}
```

The `QualifiedDo` extension is also enabled here to use `Linear.do`, a linear IO monad, which will be mentioned later.

In linear types, we can define a function like this:

```
func :: a %1 -> b
```

This function signature means that in `func`, if the return value `b` is used once, then the parameter `a` must be used once and only once; otherwise, the compiler will report an error.

In this way, several of the above security issues will receive errors from the compiler.

1. Double free: The object is used twice, which violates the rule.
2. Use-after-free: Similarly, the object is used twice, which violates the rule.
3. Memory leak: Forgetting to free, the object is never used, which violates the rule.

If you want to perform read and write operations on an object, you just need to return the object as it was after the operation is completed, thus "pretending" that the object has never been used. This is very similar to Rust's borrowing rules.

For example, filling the matrix above can be written as:

```
a <- fillMatrix a
```

And matrix multiplication can be written as:

```
(c, a, b) <- matMul c a b
```

Based on this idea, we can encapsulate the matrix operations in our FFI. We need to use the `linear-base` library, which is the de facto standard library for linear types in the Haskell community.

For IO operations, we need a dedicated Linear IO Monad. The Linear IO Monad can be converted back and forth with the original standard Monad.

```
import Prelude (IO, (>>), (>>=), fmap, return)
import Prelude.Linear
import qualified System.IO.Linear as Linear
import qualified Control.Functor.Linear as Linear

data Mat where Mat :: (Ptr CDouble) -> Mat

-- Return after consuming the resource, actually not consumed
fillMat :: Mat %1-> Linear.IO Mat
fillMat (Mat ptr) = Linear.fromSystemIO $
    cFillMatrix ptr >> 
    return (Mat ptr)

-- Same as above, looks like the resource is consumed, but it's returned
matMul :: Mat %1-> Mat %1-> Mat %1-> Linear.IO (Mat, Mat, Mat)
matMul (Mat a) (Mat b) (Mat c) = Linear.fromSystemIO $
    cMatMul a b c >>
    return (Mat a, Mat b, Mat c)

deleteMat :: Mat %1 -> Linear.IO ()
deleteMat (Mat ptr) = Linear.fromSystemIO $ free ptr
```

Then rewrite the `main` function. Here we use `Linear.do`, which can perform monad operations on `Linear.IO`:

```
main = Linear.withLinearIO $ Linear.do
    a <- newMatrix
    b <- newMatrix
    c <- newMatrix

    a <- fillMat a
    b <- fillMat b

    (c,a,b) <- matMul c a b

    deleteMat a
    deleteMat b
    deleteMat c
    Linear.return $ Ur ()
```

We can try deliberately writing some memory-unsafe code in the `main` function. We will find that no matter how we try, the compiler will report an error.

Here we use `Ur`, which indicates that the `()` value is "unrestricted" (not consumed linearly). This is a bit complicated to explain; if interested, you can look up the `linear-base` documentation and tutorials.

= Borrowing

However, using linear types to pass resources back and forth like this, writing parameters twice for each function call (once for input and once for output), looks a bit clumsy. Rust's solution is to borrow a reference and perform various operations on it. During this time, the original variable will be unavailable, and it will return after the reference leaves the scope.

In Haskell, we can achieve a similar effect to "borrowing" through a function similar to `withForeignPtr`. We call this function `borrow`.

To distinguish between *ownership* and *right of use* of resources, we introduce a new type `MatRef`. The `Mat` type indicates that we have full ownership of the matrix memory, while `MatRef` indicates that we only "borrowed" the matrix temporarily and can perform read/write operations on it, but cannot free it or transfer its ownership.

```
data Mat where Mat :: (Ptr CDouble) -> Mat

-- MatRef allows us to operate on the matrix without "consuming" the resource
data MatRef where MatRef :: (Ptr CDouble) -> MatRef

newMatrix :: Linear.IO Mat
newMatrix = Linear.fromSystemIO $ fmap Mat cNewMatrix

-- Freeing matrix resources, so it consumes a Mat type value
deleteMat :: Mat %1 -> Linear.IO ()
deleteMat (Mat ptr) = Linear.fromSystemIO $ free ptr

-- Fill matrix operation, does not consume resources, so accepts MatRef
fillMat :: MatRef -> IO ()
fillMat (MatRef ptr) = cFillMatrix ptr

-- Matrix multiplication operation, does not consume resources, so accepts MatRef
matMul :: MatRef -> MatRef -> MatRef -> IO ()
matMul (MatRef a) (MatRef b) (MatRef c) = cMatMul a b c
```

Then we implement the `borrow` function, using a little bit of polymorphism:

```
class Borrow io b where
    borrow :: Mat %1 -> (MatRef -> io b) %1-> Linear.IO (Mat, b)

instance Borrow Linear.IO a where
    borrow :: Mat %1 -> (MatRef -> Linear.IO b) %1-> Linear.IO (Mat, b)
    borrow (Mat ptr) body =
        body (MatRef ptr) Linear.>>= \x->
        Linear.return (Mat ptr, x)

instance (a ~ ()) => Borrow IO a where
    borrow :: Mat %1 -> (MatRef -> IO b) %1-> Linear.IO (Mat, b)
    borrow (Mat ptr) body =
        Linear.fromSystemIO (body (MatRef ptr)) Linear.>>= \x->
        Linear.return (Mat ptr, x)
```

By adding a type constraint, we can limit the IO operations inside `borrow` to only return unit, ensuring that no reference value "escapes" outside `borrow` and leads to unsafe memory operations.

The final effect is as follows:

```
main = Linear.withLinearIO $ Linear.do
    a <- newMatrix
    b <- newMatrix
    c <- newMatrix

    (a, (b, (c, ()))) <-
    borrow a $ \a ->
    borrow b $ \b ->
    borrow c $ \c -> do
        fillMat a
        fillMat b
        matMul c a b

    deleteMat a
    deleteMat b
    deleteMat c
    Linear.return (Ur ())
```

Inside the `borrow` function, we can perform any number of operations on `MatRef` without worrying about resources, and the code is concise and intuitive. Outside the `borrow` function, we can use linear types for fine-grained and safe management of the resource's lifecycle, achieving safe zero-cost abstractions.

= Conclusion

With linear types, Haskell can achieve memory safety comparable to Rust even when interacting with unsafe C code.

Until here, we have used imperative programming all along. Haskell also has incredibly powerful functional programming features for us to choose from, as well as type-level programming that is more convenient and powerful than C++ template metaprogramming. In short, Haskell is indeed an excellent imperative programming language.

])

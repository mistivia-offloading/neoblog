// C99 Designated Initialization
#import "/template-en.typ": *

#doc-template(
title: "C99 Designated Initialization",
date: "January 7, 2023",
body: [

C99 provides a new way of initialization: designated initialization. This initialization method is one of the few places where C and C++ are incompatible, and it is rarely taught in schools. However, this syntactic sugar is very useful and can save a lot of typing.

= Structures

```
struct S {
    int x;
    int y;
};

void foo() {
    struct S obj1 = {.x = 1, .y = 2};
    // obj1 = {1, 2}

    struct S obj2 = {.y = 2};
    // obj2 = {0, 2}
}
```

= Arrays

```
void bar() {
    int a[5] = {[2] = 2, [4] = 4};
    // a = {0, 0, 2, 0, 4}
}
```

= Mixed Use

```
struct S {
    int x;
    int y;
};

void uwu() {
    struct S sa[3] = {[1].y = 2};
    // sa = {{0, 0}, {0, 2}, {0, 0}}
}
```

= Used for Initialization on the Heap

```
struct S {
    int x;
    int y;
};

void foo() {
    struct S *ptr = malloc(sizeof(struct S));
    *ptr = (struct S){.y = 2};
    // ptr->x == 0 && ptr->y == 2
}
```

= See Also

- #link("https://floooh.github.io/2019/09/27/modern-c-for-cpp-peeps.html")[Modern C for C++ Peeps]
- #link("https://en.cppreference.com/w/c/language/initialization")[Initialization - cppreference.com]

])

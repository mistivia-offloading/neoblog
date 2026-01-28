// Living on a BSD Tree
#import "/template-en.typ":doc-template

#doc-template(
title: "Living on a BSD Tree",
date: "August 17, 2022",
body: [

FreeBSD and OpenBSD systems both come with #link("https://github.com/openbsd/src/blob/master/sys/sys/tree.h")[a very useful implementation of red-black trees and splay trees].

This implementation is header-only, has no external dependencies, and is generic. Therefore, it is very easy to use on Linux as well.

= Getting the Header File

Run:

```
curl https://raw.githubusercontent.com/openbsd/src/master/sys/sys/tree.h -o tree.h
```

This header file includes `sys/_null.h`, which does not exist on Linux. However, `tree.h` only uses this file to define `NULL`, so you can just change it to `stdlib.h`.

```
// #include <sys/_null.h>
#include <stdlib.h>
```

= Declaration

The trees in the `tree.h` header file are actually entirely macros, so they need to be expanded before use. For example, if you want the value type in the tree to be `double`, create a new header file `double_tree.h` and declare it like this:

```
#ifndef DOUBLE_TREE_H_
#define DOUBLE_TREE_H_

#include "tree.h"

struct double_treenode {
    RB_ENTRY(double_treenode) entry;
    double val;
};

int double_cmp(struct double_treenode *e1, struct double_treenode *e2);

RB_HEAD(double_tree, double_treenode);
RB_PROTOTYPE(double_tree, double_treenode, entry, double_cmp)

#endif
```

= Definition

Then create the source file `double_tree.h` and add the necessary function definitions:

```
#include "double_tree.h"

int double_cmp(struct double_treenode *e1, struct double_treenode *e2); {
    if (e1->val < e2->val) {
        return -1;
    } else if (e1->val > e2->val) {
        return 1;
    }
    return 0;
}

RB_GENERATE(double_tree, double_treenode, entry, double_cmp)
```

= Usage

Next, we will introduce how to use this `double_tree`.

== Initialization

Create the tree and initialize it:

```
RB_HEAD(double_tree, double_treenode) head;
RB_INIT(&head);
```

Initialization can also be completed in one line:

```
RB_HEAD(double_tree, double_treenode) head = RB_INITIALIZER(&head);
```

== Insertion

```
struct double_treenode *n;
double data[5] = {1.0, 2.0, 3.0, 4.0, 5.0};
for (int i = 0; i < 5; i++) {
    n = malloc(sizeof(struct double_treenode));
    n->val = data[i];
    RB_INSERT(double_tree, &head, n);
}
```

== Search and Deletion

```
struct double_treenode find;
find.val = 3.0

struct double_treenode *iter;
iter = RB_FIND(double_tree, &head, &find);

if (iter != NULL) {
    printf("Found\n");
    RB_REMOVE(double_tree, &head, iter);
    free(iter);
}
```

== Traversal

```
RB_FOREACH(iter, double_tree, &head) {
    // Do something on iter->val
    ...
}
```

In fact, `RB_FOREACH(iter, double_tree, &head)` is essentially:

```
for (iter = RB_MIN(double_tree, &head);
        iter != NULL;
        iter = RB_NEXT(double_tree, &head, iter))
```

You can use `RB_MIN` to get the minimum node in the tree; use `RB_NEXT` to get the next element of `iter`; and `RB_MAX` is the maximum node.

If you want to traverse the tree in other orders, you can use `RB_LEFT` and `RB_RIGHT`. For example, printing the tree using pre-order traversal:

```
void
print_tree(struct double_treenode *n)
{
    struct double_treenode *left, *right;

    if (n == NULL) {
        printf("nil");
        return;
    }
    left = RB_LEFT(n, entry);
    right = RB_RIGHT(n, entry);
    if (left == NULL && right == NULL)
        printf("%d", n->val);
    else {
        printf("%d(", n->val);
        print_tree(left);
        printf(",");
        print_tree(right);
        printf(")");
    }
}
```

= Others

There is a very strange thing: Arch Linux has the man documentation for `tree.h`, which you can see by executing `man 3 tree`, but the header file itself cannot be found.

This article only covers red-black trees, but splay trees are actually quite similar, so I won't go into detail. You can directly check the #link("https://www.freebsd.org/cgi/man.cgi?query=tree&sektion=3&format=html")[documentation].

= Errata

Thanks to #link("https://c7.io/@w3cing")[\@w3cing] for the #link("https://mstdn.party/@w3cing@c7.io/111659300344465706")[reminder]. The `RB_TREE` in `tree.h` provided by FreeBSD is actually not a red-black tree; RB refers to a rank-balanced tree, and the specific implementation is a weak AVL tree. FreeBSD made an #link("https://github.com/freebsd/freebsd-src/commit/e605dcc939848312a201b4aa53bd7bb67d862b18")[update] to `tree.h` in August 2020.
]
)

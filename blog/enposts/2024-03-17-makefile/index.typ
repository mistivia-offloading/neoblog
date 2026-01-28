// Common Patterns for Writing Makefiles
#import "/template-en.typ":*
#doc-template(
title: "Common Patterns for Writing Makefiles",
date: "March 17, 2024",
body: [

List all `*.c` files in the `src` directory:

```
SRC = $(shell find src/ -name '*.c')
```

List all `*.c` files in the `src` directory, but excluding `main.c`:

```
SRC = $(shell find src/ -name '*.c' -not -name 'main.c')
```

List all `*.o` files corresponding to the `*.c` files:

```
OBJ = $(SRC:.c=.o)
```

Compile all `*.c` files into `*.o` files and generate dependencies for header files (`*.d` files):

```
$(OBJ):%.o:%.c
    $(CC) -c $(CFLAGS) $< -MD -MF $@.d -o $@
```

Include the dependencies into the `Makefile` so that automatic recompilation occurs when header files are modified:

```
DEPS := $(shell find . -name *.d)

ifneq ($(DEPS),)
include $(DEPS)
endif
```

])

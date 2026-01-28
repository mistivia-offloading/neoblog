// Hook Injection
#import "/template-en.typ":doc-template

#doc-template(
title: "Hook Injection",
date: "November 15, 2022",
body: [

Hooking is a common technique in game cheat development: by placing a small piece of machine code (usually a `jmp` instruction) in the memory where a normal function would originally be, you can change the behavior of that function. This technique is not only useful in cheat development but also very helpful in software testing, where it can be used to mock a non-virtual function. Implementing a hook is also very simple.

For example, take the following code:

```
#include <stdio.h>

int func()
{
    printf("hello, beautiful world");
    return 0;
}

int main()
{
    return func();
}
```

While it would be easy to modify the `func` function directly here, assume that `func` is actually inside a dynamic link library or a static library for which we do not have the source code. In such cases, we can use a hook to modify the `func` function at runtime.

Taking x64 Linux as an example, code typically resides in the `.text` segment, where memory is non-writable. Therefore, we use the `mprotect` function to modify the memory attributes to allow writing:

```
#include <unistd.h>
#include <sys/mman.h>

// Assume the function to be hooked is orig_func
int page_size = getpagesize();
void *aligned_addr = (void *)(((uintptr_t)orig_func) & (~(page_size - 1)));
if (mprotect(aligned_addr,
             page_size * 2,
             PROT_EXEC | PROT_WRITE | PROT_READ ) != 0) {
    err_log("failed to modify mem props");
    exit(EXIT_FAILURE);
}
```

Then, write the jump machine code. Its assembly pseudo-code is as follows:

```
mov rax, &hook_func
jmp rax
```

Since the `rax` register is used to store the return value in the C/C++ ABI and can be modified at will, there is no need to worry that modifying `rax` will change the program's behavior.

The actual implementation would look like this:

```
uint8_t hook_mcode[] = {0x48, 0xB8, 0x00, 0x00, 0x00, 0x00,
                        0x00, 0x00, 0x00, 0x00, 0xFF, 0xE0};
*(uintptr_t*)(hook_code + 2) = (uintptr_t)hook_func;
memcpy(orig_func, hook_mcode, 12);
```

Finally, we have the complete code:

```
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include <unistd.h>
#include <sys/mman.h>

int func()
{
    printf("hello, beautiful world\n");
    return 0;
}

int hook_func()
{
    printf("farewell, cruel world\n");
    return 0;
}

void hook(void *orig_func, void *hook_func, uint8_t *mcode_backup)
{
    int page_size;
    void *aligned_addr;
    uint8_t hook_mcode[12] = {0x48, 0xB8, 0x00, 0x00, 0x00, 0x00, 0x00,
                              0x00, 0x00, 0x00, 0xFF, 0xE0};

    page_size = getpagesize();
    aligned_addr = (void *)(((uintptr_t)orig_func) & (~(page_size - 1)));
    if (mprotect(aligned_addr,
                 page_size * 2,
                 PROT_EXEC | PROT_WRITE | PROT_READ ) != 0) {
        fprintf(stderr, "failed to modify mem props\n");
        exit(EXIT_FAILURE);
    }
    *(uintptr_t*)(hook_mcode + 2) = (uintptr_t)hook_func;
    memcpy(mcode_backup, orig_func, 12);
    memcpy(orig_func, hook_mcode, 12);
}

void restore(void *func, uint8_t *mcode)
{
    memcpy(func, mcode, 12);
}

int main()
{
    uint8_t mcode_backup[12] = {0};
    func();
    hook(func, hook_func, mcode_backup);
    func();
    restore(func, mcode_backup);
    func();
    return 0;
}
```

The program output is as follows:

```
hello, beautiful world
farewell, cruel world
hello, beautiful world
```

The first line is the original function's output, the second line is the output after being hooked, and the last line is the output after restoration.

]
)

// Simulating RAII in C
#import "/template-en.typ":*

#doc-template(
title: "Simulating RAII in C",
date: "March 5, 2022",
body: [

#set heading(numbering: none)

Resource safety is much more difficult in C than in C++. With the RAII mechanism in C++, resource safety is quite handy. No wonder the first half of Stroustrup's "The C++ Programming Language" is about memory safety and resource safety, all of which are guaranteed by RAII. Once a local variable goes out of scope, its destructor is called, which is very convenient.

However, C language does not have such a useful tool, for example:

```c
int foo() {
    FILE* fp = fopen("bar", "w");
    if (f == 0) {
        error("failed to open file");
        return -1;
    }
    int ret = do_something(fp);
    if (ret < 0) {
        error("failed to process file");
        fclose(fp);
        return -1;
    }
    fprintf(fp, "this end it");
    fclose(fp);
    return 0;
}
```

This is just a simple example, and `fclose` appears twice here; however, when the program's control flow becomes complex, resource recovery becomes terrifying. Unlike in C++, where you only need to open an `ofstream` and then leave the rest to the destructor.

In addition to C++, other languages have similar mechanisms. For example, Java and Go have garbage collection for handling memory. As for other resources, such as file handles, network connections, mutexes, etc., Java uses `try...catch...finally...`, and Go uses `defer`.

So what should be done in C? Fortunately, GCC provides a #link("https://gcc.gnu.org/onlinedocs/gcc/Common-Variable-Attributes.html#Common-Variable-Attributes")[cleanup extension] that can be used to register destructors.

The above example of closing a file can be rewritten using this extension as follows:

```c
void close_file(FILE** fp_ptr) {
    if (*fp_ptr == NULL) return;
    fprintf(*fp_ptr, "file is closed\n");
    fclose(*fp_ptr);
}

int foo() {
    __attribute__((cleanup(close_file))) FILE* fp = fopen("bar", "w");
    if (fp == NULL) {
        error("failed to open file");
        return -1;
    }
    int ret = do_something(fp);
    if (ret < 0) {
        error("failed to process file");
        return -1;
    }
    fprintf(fp, "this end it\n");
    return 0;
}
```

With this cleanup attribute, `close_file` can be executed automatically, saving the trouble of manual management.

To make the code more compact, a lexical macro can also be added.

```c
#define CLEANUP(func) __attribute__((cleanup(func)))
```

Mutexes are similar:

```c
pthread_mutex_t mutex;
int count;

void unlock_mutex(pthread_mutex_t **mutex_ptr) {
    pthread_mutex_unlock(*mutex_ptr);
}

void *thread_run(void *arg){
    int i;
    int ret = pthread_mutex_lock(&mutex);
    if (ret != 0) {
        error("failed to acqure lock");
        return 0;
    }
    CLEANUP(unlock_mutex) pthread_mutex_t *defer_mutex = &mutex;
    for (i = 0; i < 3; i++) {
        printf("[%ld]count: %d\n", pthread_self(), ++count);
    }
    return 0;
}

int main() {
    pthread_t threads[10];
    for (int i = 0; i < 10; i++) {
        int res = pthread_create(&threads[i], NULL, thread_run, NULL);
        if (res) error("create thread error");
    }
    for (int i = 0; i < 10; i++) {
        void *ret;
        pthread_join(threads[i], &ret);
    }
    return 0;
}
```

Although this is a GCC extension, the Clang/LLVM toolchain also supports it.

If you want a more general way, you can also use the `goto` statement. Although `goto` is generally considered a bad practice, in the scenario of resource recovery, it is actually considered a good practice:

```c
int foo() {
    FILE* fp = fopen("bar", "w");
    if (f == 0) {
        error("failed to open file");
        goto clean_0;
    }
    int ret = do_something(fp);
    if (ret < 0) {
        error("failed to process file");
        goto clean_1;
    }
    fprintf(fp, "this end it");
    fclose(fp);
    return 0;

clean_1:
    fclose(fp);
clean_0:
    return -1;
}
```

Alternatively, you can also try using macros:

```c
int foo() {
    FILE* fp = NULL;
    #define DEFER \
        if (fp != NULL) fclose(fp);

    fp = fopen("bar", "w");
    if (f == 0) {
        error("failed to open file");
        DEFER return -1;
    }
    int ret = do_something(fp);
    if (ret < 0) {
        error("failed to process file");
        DEFER return -1;
    }
    fprintf(fp, "this end it");
    DEFER return 0;
    #undef DEFER
}
```

= Summary

All in all, the `goto` statement seems to be the best.

On the other hand, there is also a #link("http://www.open-std.org/jtc1/sc22/wg14/www/docs/n2895.htm")[proposal to add defer to the C language], but no one knows whether it will enter the standard, so let's wait and see.

])

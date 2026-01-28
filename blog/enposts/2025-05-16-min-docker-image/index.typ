// Building Ultra-lightweight Minimal Docker Images
#import "/template-en.typ":doc-template

#doc-template(
title: "Building Ultra-lightweight Minimal Docker Images",
date: "May 16, 2025",
body: [

Docker images built using Ubuntu as a base image easily reach hundreds of MBs or even GBs. However, in reality, a binary program does not depend on many files. If only the files necessary for running the program are kept, the image size can be significantly reduced.

Taking a Rust application as an example, this post tries to package an image that can run `ripgrep`. Compiled languages like C/C++, Go, etc., can follow the same logic.

= Preparing Files

Use the `ldd` command to view the dynamic link library dependencies of `ripgrep`:

```
ldd /usr/bin/rg
```

Result:

```
linux-vdso.so.1 (0x00007bd80ef30000)
libpcre2-8.so.0 => /usr/lib/libpcre2-8.so.0 (0x00007bd80e912000)
libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x00007bd80eefd000)
libc.so.6 => /usr/lib/libc.so.6 (0x00007bd80e722000)
/lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2
(0x00007bd80ef32000)
```

The first entry is inserted into memory by the kernel and can be ignored. Therefore, `rg` only needs four `.so` files to run at minimum.

Create a new directory:

```
mkdir rootfs
```

Write a script to copy these `.so` files to their corresponding positions in `rootfs`:

```
#!/bin/bash

copy_file () {
    local dir=$(dirname $1)
    mkdir -p rootfs/$dir
    cp $1 rootfs/$dir
}

for f in $(ldd /usr/bin/rg | grep '=>' | awk '{print $3}'); do
    copy_file $f
done
```

Run the script. Then note that

```
/lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2
(0x00007bd80ef32000)
```

Copy `ld-linux-x86-64.so.2` to `rootfs/lib64/`.

```
mkdir -p rootfs/lib64
cp rootfs/usr/lib64/ld-linux-x86-64.so.2 rootfs/lib64/
```

Then copy the `rg` binary itself to `rootfs`:

```
cp /usr/bin/rg rootfs/
```

At this point, the file system for the Docker image is ready.

= Creating the Image

Create a `Dockerfile`:

```
FROM scratch
COPY rootfs /
ENTRYPOINT ["/rg"]
```

Build the Docker image:

```
sudo docker build -t myrg .
```

Try running it:

```
sudo docker run --rm myrg --version
```

Result:

```
$ sudo docker run --rm myrg --version
ripgrep 14.1.1

features:+pcre2
simd(compile):+SSE2,-SSSE3,-AVX2
simd(runtime):+SSE2,+SSSE3,+AVX2

PCRE2 10.43 is available (JIT is available)
```

The construction of the Docker image is complete.

Check the size:

```
sudo docker images
```

Result:

```
REPOSITORY         TAG         IMAGE ID      CREATED      SIZE
localhost/myrg     latest      89ce8f41feaa  4 minutes ago  9.23 MB
```

You can see that it is only 9.23 MB.

= Chroot Jail

Actually, this method is based on the same principle as creating a chroot jail. It can also be run with `chroot`:

```
sudo chroot rootfs /rg --version
```

In reality, if such applications are really to be deployed this way, it's best to run with ordinary user permissions considering security issues.

```
sudo chroot --userspec 1000:1000 rootfs /rg --version
```

= Limitations

Some applications, especially dynamic languages like Python, rely heavily on `dlopen` to dynamically load `.so` files. These files cannot be queried with `ldd` and cannot be packaged in this way. Although `strace` can be used to analyze system calls and see exactly which files the program has opened, it is still difficult to ensure that all dynamic link libraries are copied and loaded.

Therefore, this method is generally only suitable for compiled languages, such as C/C++, Go, Rust, Haskell, etc.

])

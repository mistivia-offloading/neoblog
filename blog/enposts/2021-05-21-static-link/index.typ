// Static Linking Go and Rust
#import "/template-en.typ":*

#doc-template(
title: "Static Linking Go and Rust",
date: "May 21, 2021",
body: [

Go and Rust have a very useful feature: binary deployment. However, on Linux, the compiled binary files still depend on glibc. If the glibc versions on the development machine and the deployment machine are inconsistent, it causes trouble. Therefore, if you want to deploy binary files directly, glibc also needs to be statically linked.

= Go

```
go build -tags netgo -ldflags '-extldflags "-static"'
```

= Rust

Regarding Rust, I encountered some strange issues while trying to statically link glibc, and I couldn't solve them after searching StackOverflow for a long time. So I decided to switch to using musl. For example, on Arch Linux, it's done like this:

```
sudo pacman -S musl
rustup target add x86_64-unknown-linux-musl
cargo build --release --target x86_64-unknown-linux-musl
```

However, because musl is used, compatibility issues may sometimes arise.

])

// Some C/C++ Optimization Tools
#import "/template-en.typ":*

#doc-template(
title: "Some C/C++ Optimization Tools",
date: "November 13, 2021",
body: [

= Performance Data Collection

== perf

On Linux, perf is commonly used to collect performance data. For the use of perf, you can refer to #link("https://www.brendangregg.com/perf.html")[Brendan Gregg's website].

The most commonly used commands are `perf record` and `perf report`, and the common metrics include cycles, branch miss, cache miss, etc.

Then, the #link("https://github.com/brendangregg/FlameGraph")[FlameGraph tool] can be used to generate flame graphs, which visually display where performance is consumed.

== How perf Works

Collecting data like cycles, branch miss, and cache miss mainly utilizes the Performance Monitoring Unit (PMU) in the CPU. The PMU is actually a counter in the CPU that increments when specific events occur and can report register states to the kernel, especially the state of the Program Counter register, so that we can know where branch misses and cache misses occur.

Because it causes performance loss, a sampling mode is generally used when using the PMU. For example, a report is made only after every ten thousand cache misses.

In addition, Intel CPUs have a feature called Last Branch Record (LBR), which can record control flow and is also used by perf to find hotspots in the program.

For the principles of PMU and LBR, see:

- #link("http://rts.lab.asu.edu/web_438/project_final/Talk%209%20Performance%20Monitoring%20Unit.pdf")[Performance Monitoring Unit]
- #link("https://easyperf.net/blog/2018/06/01/PMU-counters-and-profiling-basics")[PMU counters and profiling basics. | Easyperf - Denis Bakhvalov]
- #link("https://lwn.net/Articles/680985/")[An introduction to last branch records]

= Manual Optimization

Regarding how to optimize programs, there are some common-sense clichés that apply everywhere, such as how to optimize system calls, how to use locks, using the -O3 compilation option, and so on. However, there are also some more subtle things.

One is the likely/unlikely macros, which depend on the `__builtin_expect` function in GCC. As follows:

```
#define likely(x)       __builtin_expect((x),1)
#define unlikely(x)     __builtin_expect((x),0)
```

This macro can tell the compiler which branch is more likely to be taken. Based on these hints, the compiler can make corresponding optimizations to prevent jumps that are too long, thereby improving the success rate of branch prediction and reducing the possibility of page faults when the program is loaded.

Starting from C++20, likely and unlikely have entered the C++ standard in the form of attributes. The usage is as follows:

```
double pow(double x, long long n) {
    if (n > 0) [[likely]]
        return x * pow(x, n - 1);
    else [[unlikely]]
        return 1;
}
```

In addition, there are also some builtin features that can hint the compiler to exercise more precise control over the cache, such as `__builtin_prefetch`.

See:

- #link("https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html")[Other Builtins (Using the GNU Compiler Collection (GCC))]
- #link("https://en.cppreference.com/w/cpp/language/attributes/likely")[C++ attribute: likely, unlikely (since C++20)]

= Automatic Optimization

The above manual optimization is often cumbersome in actual operation, so it can only be used in a small number of hotspots. If you want to perform a large number of optimizations on the program, it is inevitable to use automation tools.

== LTO

LTO stands for Link-Time Optimization. LTO can perform global optimization on the program instead of just focusing on local parts, so it can execute more aggressive optimization strategies. However, the disadvantage is that the optimization method is more complex and the memory consumption is large; to address these disadvantages, there is Thin LTO. LTO is also very simple to use: compile with clang, and then add `-flto` or `-flto=thin` during compilation and linking.

See:

- #link("https://llvm.org/docs/LinkTimeOptimization.html")[LLVM Link Time Optimization: Design and Implementation]
- #link("http://blog.llvm.org/2016/06/thinlto-scalable-and-incremental-lto.html")[ThinLTO: Scalable and Incremental LTO]

== PGO

PGO stands for Profile-Guided Optimization, which guides compiler optimization through Profile data by building an execution model during compilation. GCC already provides this feature. However, the disadvantage is that this process is usually very time-consuming, it is difficult to collect datasets, and building models is also complex. To this end, Google has done some work related to PGO automation and open-sourced AutoFDO (Automatic Feedback-Directed Optimization), which uses data collected from production machines for feedback optimization. However, although Google's AutoFDO is open-sourced, there seem to be no detailed instructions for use on GitHub, and only some scattered materials can be found.

See:

- #link("https://rigtorp.se/notes/pgo/")[Profile-guided optimization]
- #link("https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html")[GCC: Options That Control Optimization]
- #link("https://github.com/google/autofdo")[google/autofdo]
- #link("https://research.google/pubs/pub45290/")[AutoFDO: Automatic Feedback-Directed Optimization for Warehouse-Scale Applications]
- #link("https://clang.llvm.org/docs/UsersManual.html#using-sampling-profilers")[LLVM Docs: Using Sampling Profilers]
- #link("https://gcc.gnu.org/wiki/AutoFDO/Tutorial")[GCC Wiki: AutoFDO Tutorial]
- #link("https://stackoverflow.com/questions/4365980/how-to-use-profile-guided-optimizations-in-g")[How to use profile guided optimizations in g++?]

== BOLT

BOLT was developed by Facebook (now renamed Meta) and is also a feedback optimization, standing for Binary Optimization and Layout Tool. According to Facebook's data, BOLT brought an 8% performance improvement to their Hack language (a PHP-like) virtual machine #link("https://hhvm.com/")[HHVM].

See:

- #link("https://github.com/facebookincubator/BOLT")[facebookincubator/BOLT - GitHub]
- #link("https://engineering.fb.com/2018/06/19/data-infrastructure/accelerate-large-scale-applications-with-bolt/")[Accelerate large-scale applications with BOLT]

As its name suggests, BOLT does not require source code during optimization and can directly operate on binaries. By rearranging code and optimizing control flow, it improves the efficiency of the instruction cache. If the program depends on some binary libraries without source code, BOLT has a great advantage in this scenario.

])

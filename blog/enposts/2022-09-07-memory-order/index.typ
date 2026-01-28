// Understanding Memory Order
#import "/template-en.typ":doc-template

#doc-template(
title: "Understanding Memory Order",
date: "September 7, 2022",
body: [

C++11 and C11 both added memory order-related content to the new standards, which is a demand arising from multi-core processors and increasingly large processor caches. In multi-core processors, although multiple cores share the main memory (NUMA is not considered here), the caches are independent of each other. In this way, modern CPUs have become like a distributed system. Memory order is a very important synchronization mechanism in this distributed system.

The memory orders in the new standard include:

- Acquire
- Release
- Acquire-Release (acq-rel)
- Sequentially Consistent (seq-cst)
- Relaxed

Actually, there is also consume memory order, but mainstream compilers do not have implementations for it, and they automatically treat it as "acquire memory order". Therefore, consume memory order can be ignored.

Let's start with acquire and release. The names of these two operations come from the acquisition and release of mutexes. Here, Git can be used to help understand. The computer's main memory can be seen as a central Git repository, such as GitHub or GitLab; while the caches of each CPU can be seen as local Git repositories of developers distributed in various places.

When a thread on a CPU core reads or writes memory, it may actually be reading or writing to the cache, and these read/write operations (load/store) may not be immediately synchronized to the main memory. At this time, another thread on another CPU core may also be reading or writing to the same segment of memory, which will lead to inconsistency. Using the Git analogy, a conflict has occurred. In Git operations, we can manually resolve conflicts, but transient CPUs naturally do not have such a mechanism. Once a conflict occurs, it will only overwrite according to the order of arrival, which may lead to race conditions and, in severe cases, even process crashes.

Acquire and release are similar to pull/push. Among them, acquire is similar to `git pull`, which will pull down all the main memory states before the acquire operation, ensuring that the current cache state is up-to-date. Release is similar to `git push`, which will synchronize all modifications to the cache before the release operation to the main memory. Acq-rel, as its name suggests, is suitable for atomic operations that read and then write, pulling before reading and synchronizing after writing. Here, we can ensure that critical operations do not conflict and that there are no race conditions through synchronization and atomic operations.

However, in architectures like x86/x64, operations on all variables in memory are automatically acquire-release, which is called a strong memory model; on the contrary, ARM architecture does not have such a guarantee, and such architectures are called weak memory models. However, even in x86/x64, one cannot be careless, as compilers may perform aggressive optimizations on programs, and load/store operations may be reordered. Acquire and release will tell the compiler that reordering is not allowed here. For example, since acquire needs to ensure that all reads and writes before the operation are synchronized to the main memory, read and write operations after acquire cannot be reordered before acquire; similarly, read and write operations before a release operation cannot be reordered after release.

A typical scenario for using acquire-release is the reference count of smart pointers. When a smart pointer leaves its scope, the reference count will be decremented by 1; if the count reaches zero, it needs to be destructed and memory reclaimed. Here, it is necessary to use acquire-release. First, because memory may need to be reclaimed, it is necessary to ensure that operations on other CPU cores are visible to this thread to ensure that the reclamation behavior is correct; second, after the reclamation is completed, other threads must also be made aware of this matter; at the same time, the compiler must be prohibited from optimizing randomly and reordering the read/write order. Therefore, acquire-release is necessary.

Sequentially consistent is even more rigorous than acquire-release. It not only synchronizes to the main memory but also ensures that the caches on all CPU cores are updated, achieving an effect similar to a single core, at the cost of being slow. To reduce developer confusion, seq-cst is the default behavior for atomic operations in C++11. In contrast, release does not guarantee that all threads see the current thread's modifications; other threads are only guaranteed to see the modifications before release when they perform an acquire.

Relaxed does not involve synchronization at all; it only guarantees that the read and write of the variable currently undergoing atomic operation are atomic. Relaxed is often used for incrementing reference counts by 1, because obtaining a reference will never trigger destruction and `free` operations, so it will definitely not lead to double free or leaks. It is only necessary that the operation on the count variable itself is atomic.

However, atomic operations and memory order are still dangerous operations and should be handled with caution. If conditions permit, it is best to replace sharing with communication; if not, in the vast majority of cases, mutex and condvar are sufficient.

= References

- #link("https://www.youtube.com/watch?v=OyNG4qiWnmU")[Arvid Norberg: The C++ memory model: an intuition - YouTube]
- #link("https://en.cppreference.com/w/cpp/atomic/memory_order")[std::memory_order - cppreference.com]

]
)

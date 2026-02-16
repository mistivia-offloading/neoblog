// Simulating Mesa Monitor with C++
#import "/template-en.typ":*
#doc-template(
title: "Simulating Mesa Monitor with C++",
date: "June 20, 2019",
body: [

A Monitor is one of the synchronization mechanisms for concurrent programs. There are at least two types of Monitors: Mesa monitor and Hoare monitor. A Mesa monitor continues running after a `notify`, whereas a Hoare monitor performs a context switch after a `notify`, moving to the place where `wait` was called and starting execution there. Therefore, when writing a `wait`, a Mesa monitor requires this:

```
while (locked)
    wait();
```

But a Hoare Monitor only needs this:

```
if (locked)
    wait();
```

Currently, the Mesa Monitor is the most common.

Implementing a monitor requires language-level support. Java has the `synchronized` keyword, which can be used to implement a monitor, but C++ does not. However, we can still use condition variables and RAII to simulate a Mesa monitor.

```
#include <mutex>
#include <condition_variable>

class Monitor{
public:
    Monitor():lk{m, std::defer_lock}{}
    void notify(){cv.notify_one();}
    void broadcast(){cv.notify_all();}
    template<typename F>
    void wait(F pred){cv.wait(lk, pred);};
    std::unique_lock<std::mutex> synchronize()
    {
    return std::unique_lock<std::mutex>{m};
    }
private:
    std::mutex m;
    std::unique_lock<std::mutex> lk;
    std::condition_variable cv;
};
```

Let's look at a simple example: implementing a mutex lock using a monitor. Although this example has no practical significance, it is simple enough:

```
// To compile: g++ -std=c++14 -lpthread MonitorLock.cpp
        
#include "Monitor.h"
#include <thread>
#include <iostream>

using namespace std;
class MonitorLock{
public:
    void lock()
    {
        // unique_lock will automatically unlock through RAII
        auto lk = m.synchronize(); 
        m.wait([&](){return !locked;});
        locked = true;
    }
    void unlock()
    {
        auto lk = m.synchronize();
        locked = false;
        m.notify();
    }
private:
    Monitor m;
    bool locked = false;
};
int main()
{
    MonitorLock m;
    thread t1{[&](){
        for (int i = 1; i <= 30; i++){
            m.lock();
            cout << "t1: " << i << endl;
            m.unlock();
        }
    }};
    thread t2{[&](){
        for (int i = 1; i <= 30; i++){
            m.lock();
            cout << "t2: " << i << endl;
            m.unlock();
        }
    }};
    t1.join();
    t2.join();
    return 0;
}
```

Another example is slightly more practical: solving the Producer-Consumer problem.

```
// To compile: g++ -std=c++14 -lpthread ProducerConsumer.cpp
        
#include "Monitor.h"
#include <thread>
#include <iostream>
#include <queue>

using namespace std;
template<typename T, int N>
class ProducerConsumer{
public:
    void insert(T& item)
    {
        auto lk = m.synchronize(); 
        // if(!full)
        m.wait([&](){return items.size() < N;});
        items.push(item);
        if(items.size()  == 1){
            m.notify();
        }
        cout << "insert: " << item << endl;
    }
    T remove()
    {
        auto lk = m.synchronize();
        m.wait([&](){return items.size() > 0;}); // if(!empty)
        auto item = items.front();
        items.pop();
        if(items.size() == N-1){
            m.notify();
        }
        cout << "consume: " << item << endl;
        return item;
    }
private:
    Monitor m;
    std::queue<T> items;
};
int main()
{
    ProducerConsumer<int, 10> q;
    thread p{[&](){
        for(int i = 1; i < 30; i++){
            q.insert(i);
        }
    }};
    thread c{[&](){
        for(int i = 1; i < 30; i++){
            auto item = q.remove();
        }
    }};
    p.join();
    c.join();
    return 0;
}
```

The above example only applies to the single-producer single-consumer problem. To solve the multi-producer multi-consumer problem, one approach is to set a threshold:

```
// insert()
if (items.size() >= comsumerThreshold)
        m.broadcast();
// remove()
if(items.size() <= producerThreshold)
        m.broadcast()
```

Or control the use of condition variables with finer granularity:

```
// To compile: g++ -std=c++14 -lpthread ProducerConsumer.cpp
        
#include <thread>
#include <iostream>
#include <queue>
#include <mutex>
#include <condition_variable>

using namespace std;
template<typename T, int N>
class ProducerConsumer{
public:
    void insert(T& item)
    {
        std::unique_lock<std::mutex> lk{m};
        insert_cv.wait(lk, [&](){return items.size() < N;}); // if(!full)

        items.push(item);
        // If this were a Hoare monitor, it would jump to the remove function currently waiting,
        // unfortunately this is Mesa.
        remove_cv.notify_one();
        cout << "insert: " << item << endl;
    }
    T remove()
    {
        std::unique_lock<std::mutex> lk{m};
        remove_cv.wait(lk, [&](){return items.size() > 0;}); // if(!empty)

        auto item = items.front();
        items.pop();
        insert_cv.notify_one();
        cout << "consume: " << item << endl;
        return item;
    }
private:
    mutex m;
    condition_variable insert_cv, remove_cv;
    std::queue<T> items;
};
int main()
{
    ProducerConsumer<int, 10> q;
    thread p{[&](){
        for(int i = 1; i < 30; i++){
            q.insert(i);
        }
    }};
    thread c{[&](){
        for(int i = 1; i < 30; i++){
            auto item = q.remove();
        }
    }};
    p.join();
    c.join();
    return 0;
}
```

])

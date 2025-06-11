---
title: C++中的内存管理
date: 2025-06-07 15:36:17
modified: 2035-06-07 15:36:17
categories: C++
---
## 基本概念
### 栈内存

栈内存是由**编译器自动管理**的内存区域，用于存储局部变量、函数参数和返回地址等。栈内存的分配和释放是自动进行的：
* 当函数被调用时，局部变量和参数会被压入栈中
* 当函数返回时，这些局部变量和参数会被弹出栈并释放。
栈内存的大小固定，一般为8M左右，无法动态调整。作用域一般是函数内部，函数返回时会自动释放。

分配速度快。
#### 栈溢出
栈溢出最典型的情况就是无限递归调用导致溢出，例如
```C++
void func() {
    int arr[1000];
    func(); // 无限递归调用
}
```
#### 返回地址与栈攻击
在函数调用过程中，当前函数执行完成后应返回调用者的位置，这个位置称之为返回地址。

由于返回地址是由编译器自动管理的，其在栈内存上往往与编译器为函数内局部变量分配的内存相邻，因此攻击者可以利用这一特性，向固定大小的缓冲区写入超长的数据，覆盖返回地址，使程序跳转到提前布置好的恶意代码，这是一种典型的栈溢出攻击。
```C++
void vulnerable(char *input) {
    char buf[16];
    strcpy(buf, input); // 无边界检查,如果输入超过16字节，就可能覆盖返回地址，跳转到攻击者布置的shellcode。
}
```
 
### 堆内存

堆内存是由程序员手动管理的内存区域。大小不固定，可以动态调整，但任意出现内存泄露等问题。

作用域由程序员控制，只要不释放内存就一直存在。

与栈内存相比分配速度较慢。
### 变量和存储区
{% asset_img memory.jpg C++的内存分区 %}
c++程序的内存分为4个区域
* **代码段** 存储代码的指令，只读
* **数据段**
存储**全局变量**和**静态变量**，分为 
  * 已初始化的数据区
  进一步分为
    * 已初始化的只读区域 
    存储`const`修饰的全局变量、常量字符串等，例如`const char* str = "hello world"`这行代码中`"hello world"`存储在已初始化的只读区域，`str`放在已初始化的读写区域(注意`const char* str`是 “指向常量的指针”，所以它`str`还可以修改，只是不能通过它去修改指向的内容。)
    * 已初始化的读写区域
 
  * 未初始化的数据区（Block Started by Symbol，BSS）
  存储未初始化或初始化为0的全局变量和静态变量
* **堆区**
* **栈区**
### 内存泄露与悬空指针
* 内存泄漏指的是程序没有主动释放不再使用的内存，导致内存的占用不断增加。为了防止内存泄露，需要在不再使用内存时将其及时释放。
* 悬空指针指的则是指向了已经释放的内存的指针，为了避免悬空指针，应该在释放内存后，将指向它的指针置为`nullptr`
## 堆内存的使用
### `malloc`和`free`
* [std::malloc](https://en.cppreference.com/w/cpp/memory/c/malloc)
用于在堆上分配指定大小的内存块
    ```C++
    void * malloc(size_t size); 
    ```
  返回指向分配的内存的指针，若分配失败，则返回`nullptr`
* `calloc` 
分配内存并初始化（将所有的字节都置0）
     ```C++
    void * calloc(size_t num, size_t size); 
    ```
    * `num`要分配的元素的个数
    * `size`元素的大小（字节数）
* `realloc`
调整已分配的内存块的大小
     ```C++
    void * realloc(void* ptr, size_t size); 
    ```
    * `ptr`要调整的内存块的指针
    * `size`新的内存块大小（字节数）
    * 返回指向新的内存块的指针，若分配失败，返回`nullptr`，原来的内存块（`ptr`）保持原样。
      * 分配失败可能会导致内存泄露
        > If there is not enough memory, the old memory block is not freed and null pointer is returned.——[cppreference](https://en.cppreference.com/w/c/memory/realloc)
        
        需要手动处理
        ```C++
                int* ptr = (int*)malloc(sizeof`(int) * 10);​
        if (ptr == NULL) {​
            // 处理内存分配失败​
            return; // 或采取其他错误处理​
        }​
        ​
        // 使用临时指针保存realloc结果​
        int* temp = (int*)realloc(ptr, sizeof(int) * 20);​
        if (temp == NULL) {​
            // realloc失败：原始内存仍可通过ptr访问​
            free(ptr);   // 释放原始内存（可选）​
            ptr = NULL;  // 避免悬空指针​
            // 处理错误（例如退出或降级使用）​
        } else {​
            ptr = temp; // realloc成功，更新ptr​
            // 现在ptr指向20个int的内存​
        }
        ```
* `free`
释放通过`malloc`,`calloc`和`realloc`分配的内存空间
    ```C++
    void free(void* ptr);
    ```


#### 为什么malloc时候需要传递长度信息，而free时候却不需要传递长度信息呢?

因为`malloc(size)`在分配内存时，除了会分配一部分大小为`size`的内存供程序员使用外，还会在这部分内存头部添加这块内存的元数据，例如
```C++
struct mem_control_block {
  int is_available; 
  int size;        
};
```
这样`free`这块内存的时候就可以访问这块区域进而获取需要free的内存大小。

<!-- #### malloc的底层实现 -->

### `new`和`delete`
* `new`用于在堆上分配内存，并触发对象的构造函数，返回指向这块内存的指针
* `delete`则会触发对象的析构函数，并释放由`new`分配的内存
* `new[]`用于在堆上分配数组内存
* `delete[]`用于释放`new[]`分配的内存
* `new`和`delet`，`new[]`和`delete[]`需要配对使用，否则会导致未定义行为
* `placement new`允许在已分配的内存上构造对象，而不会分配新的内存
```C++
#include <iostream>​
using namespace std;​
​
struct A {​
    A(int a): a_(a) {}​
​
    void print() {​
        std::cout << a_ << std::endl;​
    }​
    int a_;​
};​
​
int main() {​
    char* buffer = new char[sizeof(int)];​
​    
    A* p = new A(9);
    // placement new在 buffer 上构造 A 对象​
    A* p1 = new (buffer) A(10);​
    p1->print();​
​
    // 显式调用析构函数​
    p1->~A();​
​
    // 释放内存​
    delete p;
    delete[] buffer;​
​
    return 0;​
}
```
#### `new`和`delete`的实现
在上面的代码中，`A * p = new A(9)`包含下面的步骤
* 调用C++标准库**函数**`operator new`(如果是`new []`则调用的是`operator new []`)为`A`分配一块原始的内存
* 调用`A`的构造函数，在这块内存上构造对象
* 返回指向刚刚构造的`A`对象的指针

需要注意的是，如果类`A`重载了`operator new`，则会调用`A::operator new(size_t size)`，否则调用全局函数`::operator new(size_t size)`。

运行`delete p`时，则会进行下面的操作
* 调用`p`指向对象的析构函数
* 调用C++标准库**函数**`operator delete`来释放该对象的内存，传入其的参数为`p`的值，即对象的地址。

`operator new`和`operator delete`的函数原型如下所示
```C++
void *operator new(size_t);     //allocate an object
void *operator delete(void *);    //free an object

void *operator new[](size_t);     //allocate an array
void *operator delete[](void *);    //free an array
```
#### `new []`和`delete []`的实现

与`new`和`delete`类似，`new []`和`delete []`会分别调用`operator new []`和`operator delete []`来分配和释放内存。`new[]`会调用类的构造函数依次构造数组中的每个对象，`delete []`则会调用析构函数依次将所有的对象析构。

与`new`和`delete`不同的是，`new []`在为数组分配空间时，会额外分配4字节的空间来保存数组的长度，这4个字节会放在数组内存的前面，在调用`delete []`就会读取这4个字节以确定数组的长度。

因此`void * operator delete[] (void *)`接受的参数不是指向数组的指针，而是指向数组的指针减4个字节的地址。
```C++
string *ps = new string[10];
delete [] ps;
```
以上面的代码为例，`delete [] ps`调用`operator delete[] (void *)`时，传入`operator delete[]`的参数不是`ps`而是`ps`的值减4(前移4字节，而不是`ps-4`，前移4个`string`的大小)。

对于不需要调用析构函数的对象（例如`int`等内置类型），`new[]`时不会额外多分配4个字节，`delete []`直接调用`operator delete[]`，传入的地址也不用前移4个字节，因此如果是用`new[]`分配内置类型的数组，是可以使用`delete`来释放的。

#### `new[]`和`delete[]`不配对使用的后果
##### 1. `new[]`和`delete`配对使用
```C++
#include <stdlib.h>​
#include <iostream>​
using namespace std;​
class inner {​
  public:​
  inner() { cout << "Constructing" << endl; }​
  ~inner() { cout << "Destructing" << endl; }​
};​
​
int main(int argc, char *argv[]) {​
  inner *p = new inner[2];​
  delete p;​
  return 0;​
}​
​/*
程序输出：​
Constructing​
Constructing​
Destructing​
munmap_chunk(): invalid pointer​
Aborted (core dumped)
*/
```
程序在调用了1次析构函数后挂掉。这是因为`delete`不会访问`p`的前4个字节获取长度，只调用了1次析构函数。并且`delete`传入`operator delete`的参数是`p`而不是`p`的值减4，而`p`的值减4才是一块内存的起始地址，释放内存时不从起始地址开始会出现段错误，从而导致程序整个挂掉
##### 2. `new`和`delete[]`配对使用
```C++
#include <stdlib.h>​
#include <iostream>​
using namespace std;​
class inner {​
  public:​
  inner() { cout << "Constructing" << endl; }​
  ~inner() { cout << "Destructing" << endl; }​
};​
​
int main(int argc, char *argv[]) {​
  inner *p = new inner();​
  delete []p;​
  return 0;​
}​
​/*
程序输出：​
Constructing​
Destructing​
Destructing​
Destructing​
Destructing​
Destructing​
Destructing​
...​
Destructing​
free(): invalid pointer​
Aborted (core dumped)​
*/
```
程序调用了**不定次数**的析构函数然后挂掉。这是因为`delete [] p`会往前4个字节去取数组的长度，而`new`并没有申请这4个字节的内存，因此这4个字节的内容是未知的，进而导致调用析构函数的次数是未知的。最后释放内存时使用的地址也是`p`的值减4而非正确的起始地址`p`，进而导致程序挂掉。
### `malloc`和`new`的区别

* `malloc`是C的库函数而`new`是C++运算符
* `malloc`返回`void *`，而`new`返回具体类型的指针
* 内存分配失败时，`malloc`返回`NULL`而`new`则会抛出`std::bad_alloc`异常
* `malloc`在使用时需要手动计算内存大小，而`new`不需要
* `new`会调用构造函数，而`malloc`不会
* `new`可以重载（可以重载`operator new`而非`new operator`），而`malloc`不行
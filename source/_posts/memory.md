---
title: C++中的内存管理
date: 2025-06-07 15:36:17
categories: C++
---
## 内存的分类
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
#### 返回地址
在函数调用过程中，当前函数执行完成后应返回调用者的位置，这个位置称之为返回地址。

#### 栈攻击
1. 返回地址重写
攻击者向固定大小的缓冲区写入超长的数据，覆盖返回地址，使程序跳转到恶意代码
```C++
void vulnerable(char *input) {
    char buf[16];
    strcpy(buf, input); // 无边界检查,如果输入超过16字节，就可能覆盖返回地址，跳转到攻击者布置的shellcode。
}
```
2.   
### 堆内存

堆内存是由程序员手动管理的内存区域。大小不固定，可以动态调整，但任意出现内存泄露等问题。

作用域由程序员控制，只要不释放内存就一直存在。

分配速度较慢。
## 变量和存储区
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

## 堆内存的使用

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


### 为什么malloc时候需要传递长度信息，而free时候却不需要传递长度信息呢?

因为`malloc(size)`在分配内存时，除了会分配一部分大小为`size`的内存供程序员使用外，还会在这部分内存头部添加这块内存的元数据，例如
```C++
struct mem_control_block {
  int is_available; 
  int size;        
};
```
这样`free`这块内存的时候就可以访问这块区域进而获取需要free的内存大小。

<!-- ### malloc的底层实现 -->

---
title: C++中的值类型
categories: C++
date: 2025-06-11 17:45:41
tags:
---


<!-- ## 基本定义 -->
C++中表达式的结果有两个属性：类型和值类别（value categories），类型影响值的表示范围和所占的存储空间，值类别则影响
* 能否取地址和修改
* 引用的绑定规则
* 生命周期

等特性。分为以下几类
#### 1. 左值 `lvalue`
具有存储位置的对象，可以被修改和获取，且在**表达式结束后依然存在**。简单地说，**能够用`&`取地址的就是左值**。包括
* 函数名
当我们将一个函数名作为值来使用时，它会自动转换成指向对应函数的指针
* 具名的变量 例如`std::cin`,`std::endl`
* 返回左值引用的函数调用
* 前置自增/自减运算符的表达式 例如`++i`,`--i`
* 由赋值运算符或复合赋值运算符连接的表达式 例如`a=b`、`a+=b`、`a%=b`
* 解引用表达式
* 字符串字面值 例如`"abac"`

#### 2. 纯右值 `prvalue`
不与对象的存储位置直接关联，无法获取地址且没有标识符（也就是不具名）的临时对象，包括

* 除了字符串字面量以外的字面量 例如3，`false`
* 返回非引用类型的函数调用
* 后置自增/自减运算符的表达式 例如`i++`,`i--`
* 算术表达式 `a+b`,`a&b`
* 逻辑表达 `a&&b`,`a||n`,`~a`
* 比较表达式 `a==b`
* 取址表达式 `&a` 等

#### 3. 将亡值 `xvalue`

在C++11之前的右值和C++11后的纯右值是等价的。C++11中的将亡值是随着右值引用`T&&`的引入而引入的。将亡值表达式就是下列表达式：
* 返回右值引用的函数的调用表达式
* 转换为右值引用的转换函数的调用表达式

之所以要引入右值引用和将亡值，是因为在C++中，当我们使用一个**左值**去初始化一个新对象或者给已有的对象赋值时，会调用**拷贝构造函数**或**赋值运算符**来拷贝资源。在C++11中，引入了**移动构造函数**和**移动赋值运算符**，当用**右值**来来初始化或赋值的话，这两个函数来实现，从而避免拷贝，提高效率。这个右值完成为左值初始化或赋值的任务后，它的资源已经被移动给了这个左值，其本身马上就会被析构。也就说，这个右值在被定义时，它就是“将亡”的了。
#### 4. 广义左值和右值
广义左值包含左值和将亡值，右值包含纯右值和将亡值。
#### 值类型的辨析
##### 1. 字符串字面量是左值
字符串字面值是所有字面值中唯一的左值，而其他的字面值都是右值，这是因为早期间C++将字符串字面值实现为`char`类型的数组，为每个字符都分配了空间并允许进行操作。
```C++
cout<<&("abc")<<endl;
char *p_char="abc";//注意不是char *p_char=&("abc");
```
例如上面的代码，字符串字面量`"abc"`可以直接用来取地址和给指针赋值，`p_char`的值就是字符串首字母`'a'`的地址
##### 2. 具名的右值引用是左值，不具名的右值引用是右值
```C++
#include <iostream>
#include <utility>

// 两个重载，用于区分传入的是左值还是右值
void identify(int& x) {
    std::cout << "Called identify(int&): lvalue\n";
}
void identify(int&& x) {
    std::cout << "Called identify(int&&): rvalue\n";
}

int main() {
    int a = 10;

    // 1. 普通左值
    identify(a);            // 匹配 int&  —— 输出 lvalue

    // 2. 字面右值
    identify(20);           // 匹配 int&& —— 输出 rvalue

    // 3. 具名的右值引用
    int&& r = 30;           // r 的类型是 int&&，但它有名字
    identify(r);            // r 是一个有名字的表达式，所以被当作左值 —— 输出 lvalue

    // 如果想把 r 当作右值，需要 std::move（或 static_cast<int&&>）
    identify(std::move(r)); // 输出 rvalue

    // 4. 不具名的右值引用（临时对象）
    identify(int&&(40));    // 直接构造的临时右值 —— 输出 rvalue

    return 0;
}
```
##### 3. `++i`和`i++`
* `++i`是先把`i`加1再赋值给`i`，表达式返回的值就是`i`，因此它的结果是具名的，`i`在表达式结束后依然存在，因此`++i`是左值
* `i++`则是先对`i`进行拷贝，将拷贝的副本返回后再对`i`加1，由于返回的结果是`i`的拷贝，因此是不具名的，是纯右值
#### 左值与右值的转换
可以使用`std::move`将左值转换成右值
```C++
#include <iostream>
#include <utility>

// 两个重载，用于区分传入的是左值还是右值
void identify(int& x) {
    std::cout << "Called identify(int&): lvalue\n";
}
void identify(int&& x) {
    std::cout << "Called identify(int&&): rvalue\n";
}

int main() {
    int a = 10;
    // 如果想把 r 当作右值，需要 std::move（或 static_cast<int&&>）
    identify(std::move(r)); // 输出 rvalue

    return 0;
}
```

#### 万能引用
当
* `T`是一个模板参数，且需要进行类型推导，或者
* 使用`auto &&`声明变量

时，`T&&`或`auto &&`既可以绑定到左值也可以绑定到右值，称之为**万能引用**。

为了达成`T&&`或`auto &&`的上述功能，C++规定，当应用的引用出现时，会通过引用折叠简化为单一引用
* `& &`    → `&`
* `& &&`   → `&`
* `&& &`   → `&`
* `&& &&`  → `&&`

例如
```C++
template<typename T>​
void foo(T&& arg) { ​
    // arg 是万能引用，可以绑定到左值或右值​
}​
​
int main() {​
    int a = 10;​
    foo(a);       // T 推导为 int& → arg 类型是 int&（左值引用）​可以这样理解：为了让T&&折叠为int &&，所以推导T为int​
    foo(10);      // T 推导为 int  → arg 类型是 int&&（右值引用）​
}​
```
#### 完美转发
通过`std::forward<>`模板，我们能够实现**完美转发**，即在参数传递时**保留其原始的值类型**
```C++
#include <iostream>​
​
template <class T>​
void process(T &&t)​
{​
    std::cout << t << " is " << "rvalue\n";​
}​
​
template <class T>​
void process(T &t)​
{​
    std::cout << t << " is " << "lvalue\n";​
}​
​
template<typename T>​
void wrapper(T &&t)​
{​
    process(std::forward<T>(t));​
}​
​
template<typename T>​
void wrapper_common(T &&t)​
{​
    process(t);​
}​
​
int main()​
{​
    // 测试右值引用​
    wrapper(1); // rvalue​ 
    // 测试左值引用​
    int i = 1;​
    wrapper(i); // lvalue​ 两个process模板都可以时，编译器会选择更加specialized那个
​
    // 测试完美转发将亡值​
    wrapper(std::move(i)); // rvalue​
​
    int j = 2;​
    // 测试不用完美转发​
    wrapper_common(std::move(j)); // lvalue​
    return 0;​
}
```
* 万能引用是参数绑定的入口，负责接收任意的值类别。​
* 而`std::forward`是转发的出口，负责恢复原始值的类别。以上面的代码为例，`wrapper`中的`t`无论接受的是左值还是右值，在`wrapper`内部都是左值，因为它是**具名**的，且在栈上分配了空间。而`std::forward<T>(t)`则能根据`T`是`int`(`t`传入的是右值)还是`int &`（`t`传入的是左值）来将`t`恢复成它原来的值类型。
#### 参考
* [[cnblog] 话说C++中的左值、纯右值、将亡值](https://www.cnblogs.com/zpcdbky/p/5275959.html)
* [C++中的万能引用和完美转发](https://theonegis.github.io/cxx/C-%E4%B8%AD%E7%9A%84%E4%B8%87%E8%83%BD%E5%BC%95%E7%94%A8%E5%92%8C%E5%AE%8C%E7%BE%8E%E8%BD%AC%E5%8F%91/)

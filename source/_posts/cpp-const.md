---
title: C++中的const关键字
categories: C++
date: 2025-06-08 19:37:04
tags:
---

## `const`关键字的使用
`const`关键字可以修饰C++的内置变量、指针、自定义对象、成员函数、返回值和函数参数，以告诉编译器某些值需要保持不变的。也就是说，`const`关键字是在编译过程中发挥作用的。

### `const`修饰普通类型的变量
当一个变量被`const`修饰时，程序不能改变这个变量的值
### `const`修饰指针变量
`const`修饰指针变量时，情况会变复杂，有三种情况
1. `const`修饰指针指向的内容
此时该指针指向的内容是不可修改的，更准确的说，是**不能通过这个指针来修改它指向的内容**
    ```C++
    int a = 8;
    const int * p = &a;
    int const * p = &a;//两种写法等价
    *p = 9; //错误的
    a = 9;//正确的
    ```
1. `const`修饰指针
即指针常量，指针不能修改
    ```C++
    int a = 8;
    int* const p = &a;
    *p = 9; // 正确
    int  b = 7;
    p = &b; // 错误
    ```
1. `const`修饰指针和指针指向的内容
则既不能通过指针修改指向的内容，也不能修改指针本身
    ```C++
    int a = 8;
    const int * const  p = &a;
    ```
为了更好地理解上述的三种情况为什么这样声明，推荐阅读[C Right-Left Rule (Rick Ord's CSE 131](https://cseweb.ucsd.edu/~gbournou/CSE131/rt_lt.rule.html)

### `const`修饰函数参数和返回值
`const`修饰函数参数时，参数在函数体内无法被修改。最常见的情况是用`const`修饰指针防止其被意外篡改，以及`const`+引用传递以免去自定义类型在值传递时构造临时对象的开销。

<!-- 要理清`const`修饰函数返回值对返回值的影响，首先要明白在C/C++中，函数的返回值总是**按值**返回的，函数会把返回值复制到一个外部的临时变量`a`，这个变量时可以被拷贝的。如果有在函数被调用后，有外部变量`b`能够“接住”`a`，那么`a`会被拷贝到`b`（对于自定义的变量，则会调用赋值构造函数），然后将`a`释放，如果没有变量“接住”`a`，则直接释放。接下来我们分析`const`修饰函数返回值时，三种不同的情况 -->
`const`修饰函数返回值时，有下面三种不同的情况
1. 修饰内置类型的返回值
返回的是一个临时变量，`const`修饰没有实际意义，与不修饰时一样
2. 修饰自定义类型的返回值
则返回值不能作为左值使用，既不能被赋值也不能被修改.同时也不能调用返回对象的非`const`成员函数
3. 修饰指针或引用类型的返回值
   * 函数返回指向常量的指针
        ```C++
        const int * func();
        const int * p =func();
        *p = 10;       // 错误
        p++; //正确
        ```
    * 函数返回指针常量
        ```C++
        int* const func();
        int* const p = func();
        *p = 10;       //正确
        p++;  //错误
        ```
    * 函数返回指向常量的指针常量
        ```C++
        const int* const func();
        const int* const p = func();
        *p = 10;       //错误
        p++;  //错误
        ```
    * `const`修饰引用返回值
    返回一个只读的引用
        ```C++
        const MyClass& func();
        const MyClass& ref = func();
        ref.setValue(10); //错误
        ```
### `const`修饰类的成员函数
在成员函数的标识符后面修饰，保证在调用过程中不会修改对象中任何没有`mutable`修饰的成员变量。
```C++
class Test
{
public:
    Test(){}
    Test(int _m):_cm(_m){}
    int get_cm()const
    {
       return _cm;
    }
 
private:
    int _cm;
};
```
注意：`const`关键字不能与`static`关键字同时使用，因为`static`关键字修饰静态成员函数，静态成员函数不含有`this`指针，即不能实例化，`const`成员函数必须具体到某一实例。

## `volatile`关键字

`volatile`修饰的变量表示其可以被某些编译器未知的因素修改。例如
* 操作系统
* 硬件
* 其他的线程
这样编译器就不会对`volatile`修饰的变量进行优化。例如
```C++
volatile int i=10;
int a = i;
...
// 其他代码，并未明确告诉编译器，对 i 进行过操作
int b = i;
```
在上面的代码中，无论是将`i`赋值给`a`还是`b`，都要从`i`的地址中读取值，而如果`i`没有被`volatile`修饰，那么编译器就会优化对`b`的赋值，直接将上次从`i`的地址中读取的值赋值给`b`,而不是重新读取`i`的地址中的值。
```C++
const volatile int a = 10;
```
上面的代码也是合法的，·且`const`和`volatile`关键字都能发挥作用
* 在`a`的作用域内，无法对`a`进行修改，因为它是`const`修饰的
* 但是`a`的值可能被其他线程或者别的外部事件改变，因为它是`volatile`修饰的
  
## `mutable`关键字
`mutable`关键字用于修饰类的成员变量。
  * 当成员变量被`mutable`修饰时，表示该变量时可变的，即使包含它的对象被声明为`const`类型
  * `mutable`修饰成员变量不会影响其在类外部的可见状态


## `const`与`#define`的区别

* `#define`是预处理指令，在预处理阶段对宏定义进行分析和替换，而`const`是关键字，是由编译器在编译阶段处理的
* `#define`没有作用域的限制（但也得在`#define`后使用啊不然就违反因果律了），宏可以被定义在当前程序的任意位置或者被其包含的头文件中，只有遇到对应的`#undef`才失效。而`const`修饰的变量有作用域的限制。
    ```C++
    namespace definePI {
        #define PI 3.1415926
        const float pi = 3.1415926;
    }

    int main() {
        printf("%f\n", PI);      // 输出3.1415926
        printf("%f\n", pi);      // 编译错误
        #undef PI
        printf("%f\n", PI);      // 编译错误
        printf("%f\n", E);       // 编译错误
    }

    namespace defineE {
        #define E 2.7182818
    }

    ```
* `#define`可以重定义（需要先`#undef`取消定义）但是`const`不行
    ```C++
    #define X 30
    const int Y=10;

    int main()
    {
        cout<<"Value of X: "<<X<<endl; //输出30
        #undef X
        #define X 300
        cout<<"Value of X: "<<X<<endl; //输出300
        
        cout<<"Value of Y: "<<Y<<endl; //输出10
        Y=100;	//error, we can not assign value to const
        cout<<"Value of Y: "<<Y<<endl;
        return 0;
    }
    ```
* 
## 参考
* [[RUNOOB] C++ const 关键字小结](https://www.runoob.com/w3cnote/cpp-const-keyword.html)
* [[RUNOOB] C/C++ 中 volatile 关键字详解](https://www.runoob.com/w3cnote/c-volatile-keyword.html)
* [[cppreference.com] C++ keyword: const](https://en.cppreference.com/w/cpp/keyword/const.html)
* [[cppreference.com] cv (const and volatile) type qualifiers](https://en.cppreference.com/w/cpp/language/cv.html)
* [[cppreference.com] C++ keyword: volatile](https://en.cppreference.com/w/cpp/keyword/volatile.html)

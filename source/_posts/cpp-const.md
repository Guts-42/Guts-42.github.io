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
## `constexpr`
`constexpr`在C++11中被引进，字面意思是`const expression`。`constexpr`修饰的变量是编译期常量，且必须用常量表达式初始化。
```C++
constexpr int mf = 20;              //正确，20是常量表达式
constexpr int limit = mf + 1;       //正确，mf + 1是常量表达式
constexpr int sz = size();         //未知，若size()函数是一个constexpr函数时即正确，反之错误。

int i = 10;
constexpr int t = i;                //错误，i不是常量
```
### `literal type`
`constexpr`只能用于修饰`literal type`的变量，一个变量是`literal type`当且仅当它属于下面的类型
* 标量类型 [scalar type](https://en.cppreference.com/w/cpp/named_req/ScalarType.html)
包含
  * 算数类型
  * 枚举类型
  * 指针类型
  * 指向类成员的指针类型
  * `std::nullptr_t`
  * 以上类型的`cv`限定版本（即用`const`或`volatile`修饰的版本）
* 引用
* `literal type`的数组
* 具有以下所有性质的`cv-qualified`类
  * 拥有平凡(`trivial`)析构函数（即默认析构函数）（C++20前的版本）或`constexpr`析构函数(C++20)
  * 所有非静态且非`variant`的成员（`variant`变量在编译时无法确定变量的具体类型）和基类都不是`volatile`修饰的`literal type`, 并且是下面几种类型之一
    * `lambda`类型
    * 满足下列条件的聚合`union`
      * 没有`variant`成员
      * 或者至少有一个非`volatile`修饰的`literal type`的`variant`成员
    * 非`union`的聚合类型，并且每个匿名联合体成员也都满足
      * 没有`variant`成员
      * 或者至少有一个非`volatile`修饰的`literal type`的`variant`成员
    * 具有至少一个`constexpr`构造函数的类型，且该构造函数不是拷贝或移动构造函数
  
### 与`const`的区别
* `const`修饰的变量可以在运行时才初始化，而`constexpr`则一定会在编译期初始化。​
* 而`const`表示的是read only的语义，只保证修饰的变量运行时不可以被直接更改，并未区分是编译期常量还是运行期常量。​
### `constexpr`指针
`constexpr`只对指针本身有效，而不会对指针指向的对象生效
```C++
const int *p = nullptr;            //正确，p是一个指向整型常量的指针, p本身可以被修改，但是p指向的内存无法通过p来修改
constexpr int *q = nullptr;        //正确，但q是一个指向  整数  的  常量指针，q无法被修改
```
一个`constexpr`指针的初始值必须是`nullptr`或者`0`，或者是指向存储于某个固定地址中的对象。
### `constexpr`函数
`constexpr`修饰的函数要求其返回类型以及所有的形参都是`literal type`，且函数体中必须有且仅有一条`return`语句(除非函数的返回值是`void`)。这样在它们被调用时，编译期会把它们直接展开替换为结果值。
```C++
constexpr int new_sz() { return 42; }//constexpr函数
constexpr int foo = new_sz();
//在对变量foo初始化时，编译器把对constexpr函数的调用替换成其结果值。为了能在编译过程中随时展开，constexpr函数被隐式地指定为内联函数。
```
有意思的是，C++允许`constexpr`返回的值不是常量
```C++
//如果cnt是常量表达式，则scale(cnt)也是常量表达式
constexpr size_t scale(size_t cnt){ return new_sz() * cnt; }

//当scale的实参是常量表达式时，它的表达式也是常量表达式，反之则不然
int arr[scale(2)];	//正确：scale(2)是常量表达式
int i = 2;			//i不是常量表达式
int a2[scale(i)];	//错误：scale(i)不是常量表达式
```
前面提到返回值类型为`void`的函数也可以用`constexpr`来修饰，乍一看这样的函数没有任何意义，但实际上`constexpr`修饰的函数除了返回值是编译期常量外，还在编译期运行，这样就能在编译期执行一些操作。
### 使用场景
数组大小、模板参数和`switch`语句都要求编译期常量，使用`constexpr`修饰的变量或函数可以用于这些场景。
```C++
constexpr int n = 10;
const int cn = 10;
int arr[n]; //正确
int arr[cn]; //报错
```


## 参考
* [[RUNOOB] C++ const 关键字小结](https://www.runoob.com/w3cnote/cpp-const-keyword.html)
* [[RUNOOB] C/C++ 中 volatile 关键字详解](https://www.runoob.com/w3cnote/c-volatile-keyword.html)
* [[cppreference.com] C++ keyword: const](https://en.cppreference.com/w/cpp/keyword/const.html)
* [[cppreference.com] cv (const and volatile) type qualifiers](https://en.cppreference.com/w/cpp/language/cv.html)
* [[cppreference.com] C++ keyword: volatile](https://en.cppreference.com/w/cpp/keyword/volatile.html)
* [[cppreference.com] C++ named requirements: LiteralType (since C++11)](https://en.cppreference.com/w/cpp/named_req/LiteralType)
* [[cnblog] C++11新特性：constexpr变量和constexpr函数](https://www.cnblogs.com/ljwgis/p/13095739.html)

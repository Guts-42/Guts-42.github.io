---
title: C++中的异常处理
categories: C++
date: 2025-06-10 19:31:22
tags:
---

## 异常处理的基本操作
C++中通过下面的三个关键字来是实现异常处理
* `try` 
用于标记可能出现异常的代码块，被`try`标记的代码块称为保护代码
* `throw`
当在保护代码中遇到异常时，可以通过`throw`关键字来将异常抛出
* `catch`
跟在保护代码后面,`catch`关键字能够捕获`throw`抛出的异常，并根据异常的类型进行不同的处理

**示例**
```C++
#include <iostream>
using namespace std;
 
double division(int a, int b)
{
   if( b == 0 )
   {
      throw "Division by zero condition!"; //throw抛出了const char*类型的异常
   }
   return (a/b);
}
 
int main ()
{
   int x = 50;
   int y = 0;
   double z = 0;
 
   try {
     z = division(x, y);
     cout << z << endl;
   }catch (const char* msg) { //catch捕获throw抛出的异常
     cerr << msg << endl; //对异常进行处理
   }
 
   return 0;
}
```

## C++异常类

`throw`和`catch`既可以抛出和捕获基础类型的异常，也可以使用C++预定义的异常类，这些异常类有统一的的接口，便于我们进行异常的捕获和处理。

C++预定义的异常类包括：

* `std::exception`：所有标准异常的基类。​
  * `std::bad_alloc`：内存分配失败时抛出。​
  * `std::bad_cast`：动态类型转换失败时抛出。​
  * `std::bad_typeid`：使用typeid运算符失败时抛出。​
  * `std::bad_exception`：在函数声明中使用了异常规格，但抛出了未列出的异常时抛出（C++11已弃用）。​
  * `std::logic_error`：逻辑错误异常基类，包括：​
    * `std::domain_error`：数学域错误，如sqrt(-1)。​
    * `std::invalid_argument`：无效参数错误。​
    * `std::length_error`：超出允许长度的错误。​
    * `std::out_of_range`：范围错误，如访问vector的非法索引。​
  * `std::runtime_error`：运行时错误异常基类，包括：​
    * `std::overflow_error`：上溢错误。​
    * `std::range_error`：范围错误（与std::out_of_range不同，用于其他情况）。​
    * `std::underflow_error`：下溢错误。​
上面的异常类最常使用的核心接口`.what()`，返回`const char *`，用于说明异常的情况。

**标准异常类的示例**
```C++
#include <iostream>​
#include <stdexcept>​
using namespace std;​
​
void testLogicError() {​
    throw invalid_argument("Invalid argument error!");​
}​
​
void testRuntimeError() {​
    throw out_of_range("Out of range error!");​
}​
​
int main() {​
    try {​
        testLogicError(); // 抛出逻辑错误异常​
    } catch (const logic_error& e) {​
        cout << "Caught a logic_error: " << e.what() << endl;​
    }​
​
    try {​
        testRuntimeError(); // 抛出运行时错误异常​
    } catch (const runtime_error& e) {​
        cout << "Caught a runtime_error: " << e.what() << endl;​
    }​
​
    return 0;​
}
```

此外，还可以通过继承`std::exception`并重载`what`来实现自定义的异常类。

**自定义异常类的示例**
```C++
#include <iostream>​
#include <exception>​
#include <string>​
using namespace std;​
​
class MyException : public exception {​
public:​
    MyException(const string& message) : message_(message) {}​
​
    virtual const char* what() const noexcept override {​
        return message_.c_str();​
    }​
​
private:​
    string message_;​
};​
​
void testCustomException() {​
    throw MyException("Custom exception occurred!");​
}​
​
int main() {​
    try {​
        testCustomException(); 
    } catch (const MyException& e) {​
        cout << "Caught a MyException: " << e.what() << endl;​
    } catch (const exception& e) {​
        cout << "Caught an unknown exception: " << e.what() << endl;​
    }​
​
    return 0;​
}​
```

## `noexcept`

从C++11开始，可以使用`noexcept`修饰函数，声明函数不会抛出任何异常，这有利于编译器做更多的优化
```C++
void func() noexcept; // 声明函数不抛出任何异常​
```
此外，`noexcept`还可以作为运算符，传入函数来验证某个函数是否被`noexcept`修饰
```C++
void may_throw();​
void no_throw() noexcept;​
int main() {​
  noexcept(may_throw()); // false​
  noexcept(no_throw()); // true​
}
```
类的析构函数默认是`noexcept`的
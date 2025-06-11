---
title: C++中的引用
categories: C++
date: 2025-06-09 15:14:59
tags:
---

引用是一种特殊的变量别名机制，它
* 是变量的别名，既不是变量本身，也不是变量的拷贝。
* 在定义时必须被初始化，且一旦被绑定到一个变量上，就不能再被绑定到另一个变量上，与指针相比更加安全（但也并非完全安全，引用也依赖于绑定对象的有效性，如果绑定的对象内存被释放，则引用的行为是未定义的）。
* 必须被绑定到有效的对象，不能为`nullptr`，这就可以天然地避免空指针的问题。
* 操作简单。

## 引用的作用
* 作为别名
    可以简化复杂数据的访问
    ```C++
    struct Person{
        std::string name;
        std::vector<int> grades;
    }
    Person guts{"Guts",{80,99,59}};
    std::string & english_grade = guts.grades[2];
    english_grade++;
    ```
* 作为参数传递
  * 避免拷贝开销
  * 允许修改实参
  * `const`引用作为参数也是有意义的，可以避免拷贝开销，并且`const`引用还可以绑定右值
* 作为函数返回值
  * 可以用于链式调用，函数返回引用，引用又调用函数
    ```C++
    std::ostream& operator<<(std::ostream& os, const MyClass& obj) {​
        os << obj.data();​
        return os;  // 允许链式调用
    }
    std::cout << obj1 << obj2;//等价于std::cout << obj1.data() << obj2.data();
    ```
  * 用于实现运算符的重载
    ```C++
    MyClass& MyClass::operator=(const MyClass& other) {​
        if (this != &other) {​
            // 赋值操作​
        }​
        return *this;  // 返回当前对象的引用​
    }
    ```
* 右值引用 
右值引用`T&&`可以绑定右值(`const`引用也可以)，通常用于移动语义，避免深拷贝。
    ```C++
    int&& x = 42;     // 合法，右值引用绑定字面量（右值）
    int& y = 42;      // 错误，左值引用不能绑定右值
    const int& z = 42;// 合法，const引用也可以绑定右值

    class MyString {​
    public:​
        MyString(MyString&& other) noexcept ​
            : data_(other.data_), size_(other.size_) {​
            other.data_ = nullptr;  // 转移资源所有权​
        }​
    };
    ```
* `const`引用
  `const`引用也可以绑定右值
  ```C++
    void func1(string& a) {
	
    }
    void func2(const string& a) {
    }
    int main() {
        func1("12323");//变异失败，因为string &作为一个引用类型，必须要知道它绑定对象的地址才行，而输入值是const char*类型的右值
        func2("12323");
    } 

  ```
### 与指针的区别
```C++
#include <iostream>​
​
int main() {​
    int x = 10;​
    //代码段1
    int& ref = x;  // 编译器等价处理为 int* const ref = &x;​
    ref = 20;      // 等价于 *ref = 20;​
    ​//代码段2
    int* ptr = &x;​
    *ptr = 30;​
    return 0;​
}​
```
代码段1和代码段2在生成的汇编代码中除了数字外完全一样，因为引用本质上是通过指针常量来实现的。
| 特性 | 引用 | 指针 |
| :--- | :--- | :--- |
| 初始化要求 | 必须初始化，且不可重新绑定到其他对象 | 可以声明为空指针（`nullptr`），后续可修改指向 |
| 空值合法性 | 不允许空引用 | 允许空指针（`nullptr`） |
| 内存占用 | 不占用显式内存（编译器优化） | 占用独立内存（存储地址值） |
| 操作语法 | 直接使用对象语法（无`＊`或 `->` ） | 需用`＊`解引用或 `->` 访问成员 |
| 类型安全性 | 强类型绑定，无类型转换风险 | 允许 `void＊`和危险的类型转换 |
| 多级间接访问 | 仅支持单层引用（无引用的引用） | 支持多级指针（`int＊＊`） |
| 内存地址可见性 | 无法直接获取引用的地址（`＆ref` 返回原对象地址） | 可直接获取指针变量的地址（`＆ptr`） |
1. 当需要指向空值或重新指向另一个对象时，使用指针。
2. 当需要在函数间安全地传递大型对象或需要修改函数参数时，优先考虑引用（除非有指向空或重新指向的需求）。
3. 在需要动态内存分配或管理内存时，使用指针。
4. 在需要避免拷贝大型对象以提高效率时，使用引用（特别是作为函数参数或返回值）。
###
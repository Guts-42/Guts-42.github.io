---
title: C++中的enum class
categories: C++
date: 2025-06-08 21:15:02
tags:
---

## 与`enum`的对比
C++11之所以要引入`enum class`，是因为传统的`enum`
* 作用域不限范围，会造成命名空间的污染
    ```C++
    enum Color{black,white,red};	//black、white、red作用域和color作用域相同

    auto white = false;	//错误，white已经被声明过了
    ```
    而`enum class`的枚举成员默认具有强作用域，需要通过枚举类型名来访问，能够降低命名空间的污染
    ```C++
    enum class Color{black,white,red}; //black、white、red作用域仅在大括号内生效

    auto white = false;		//正确，这个white并不是Color中的white

    Color c = white;	//错误，在作用域范围内没有white这个枚举量

    Color c = Color::white;	//正确

    auto c = Color::white;	//正确
    ```
* 会发生隐式类型转换
    ```C++  
    enum Color{black,white,red};
    std::vector<std::size_t> primeFactors(std::size_t x);	//函数返回x的质因数

    Color c = red;

    if(c < 14.5)	//将color型别和double型别比较，发生隐式转换
    {
        auto factors = primeFactors(c);  //计算一个color型别的质因数，发生隐式转换
    }
    ```
    而`enum class`的元素只能通过`static_cast`进行强制类型转换
* 不能进行前置声明，而`enum class`可以
    ```C++
    enum Color;			//错误
    enum class Color;	//正确
    ```
    
## 参考
* [[CSDN]C++11枚举类——enum class](https://blog.csdn.net/weixin_42817477/article/details/109029172)
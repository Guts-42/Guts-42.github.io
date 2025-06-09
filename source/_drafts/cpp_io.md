---
title: C++的标准输入输出
date: 2025-06-05 20:18:49
# tags: 你好
categories: C++
---


- `std::cout`  和  `std::cerr`  都是 `ostream`  类型的对象。
- `std::cin`
  - `>>`指向`std::string`类型时读取一行文本
  - 会忽略空白字符（如空格、制表符、换行符）
  - 成员函数fail()用于判断输入流是否出错
    ```C++
    int num;
    
    std::cin >> num;
    
    if (std::cin.fail()) {
    
        std::cerr << "Error: invalid input" << std::endl;
        std::cin.clear(); // 清除错误状态
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); // 忽略错误的输入
    } 
  - 可以通过`stringstream`实现格式化输入
    ```C++
    std::string input;
    
    std::cin >> input;
    
    std::stringstream ss(input);
    
    int a, b;
    
    ss >> a >> b;
- `std::cout`
  - `<< std::endl`在添加换行符的同时会刷新输出缓冲区
  - 支持格式化输出
      ```C++
      std::cout << std::setw(10) << std::left << "Name: " << "John Doe" << std::endl;

      std::cout << std::fixed << std::setprecision(2) << "Pi: " << pi << std::endl;
      ```
    - `std::setw(n) `
设置下一个字段的最小宽度为n， 如果实际字符串长度小于 n，会在不足的部分自动填充空格；如果实际字符串长度超过 n，则会按实际长度输出，不会截断。
    - `std::left`
设置接下来的字段左对齐（默认是右对齐）
    - `std::fixed`
设置浮点数的输出格式为小数点格式
    - `std::setprecision(n)`
设置后续浮点数输出时保留的小数位数
  - 通常会缓冲输出，直到缓冲区满了或者显式地调用  `flush`  函数。
可以在输出后调用  `std::cout.flush()`  来立即刷新缓冲区。
- `std::cerr` 标准错误输出
  - 通常不缓冲输出
  - 通常不格式化
- `std::clog` 输出日志信息
  - 通常使用输出缓存
  - 支持格式化输出
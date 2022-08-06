use std::collections::HashMap;

use clap::Parser;

#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct Args {
    /// Name of the person to greet
    #[clap(short, long, default_value = "dev")]
    name: String,

    /// Number of times to greet
    #[clap(short, long, default_value_t = 1)]
    count: u8,
}

fn add_one(i: i32) -> i32 {
    return i + 1;
}

fn test_for_loop() {
    for i in 1 ..=5 {
        println!("i is {}", i);
    }

    let mut list = [1,2,3];

    // 可变借用
    for li in &mut list {
        println!("list item is {}", li);
        *li = *li + 1;
    }

    // array pretty print
    println!("array is {:?}", list);

    // 循环N次, c style
    for _ in 0..3 {
        println!("hi!");
    }
}

fn test_basic() {
    let v = Some(3u8);
    if let Some(_) = v {
        println!("not nothing");
    }

    let mut dict = HashMap::new();
    dict.insert("k", "v");
    let e = dict.entry("k2").or_insert("love");
    *e = "go";
    println!("dict {:?}", &dict)

}

struct Rect {
    width: u32,
    height: u32,
}

impl Rect {
    // 没有self参数的: 关联函数, 构造数据惯用new;
    // 例子: String::from
    fn empty() -> Rect {
        Rect {
            width: 1,
            height: 1,
        }
    }

    fn area(&self) -> u32 {
        self.width * self.height
    }
}


// 函数之外,结构体,枚举,方法都可以使用泛型. 支持特化
// const泛型 针对值的泛化,用来支持数组.
// 不同长度的数组类型不一样
// rust泛型没有运行时开销,一贯的零成本抽象; 编译时
// 会根据用到的类型生成多份代码,会增加编译时间和目标
// 代码size

// 特征与类型: 至少有一个是在当前作用域定义的.
// 这样可以避免修改无关的内容.

// 特征对象 动态派发


fn main() {
    let args = Args::parse();

    println!("Hello, {}, {}", args.name, args.count);

    let x: i32 = "52".parse().expect("not a number");
    println!("2022-2-11 wsl lunar neovim {}", add_one(x));
    println!("how error handling is in rust?");

    test_for_loop();
    test_basic();

    let r = Rect::empty();
    println!("r area: {}", r.area());

}

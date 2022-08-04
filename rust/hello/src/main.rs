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

}

fn main() {
    let args = Args::parse();

    println!("Hello, {}, {}", args.name, args.count);

    let x: i32 = "52".parse().expect("not a number");
    println!("2022-2-11 wsl lunar neovim {}", add_one(x));
    println!("how error handling is in rust?");

    test_for_loop();
    test_basic();
}

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

fn main() {
    let args = Args::parse();

    println!("Hello, {}, {}", args.name, args.count);

    let x: i32 = "52".parse().expect("not a number");
    println!("2022-2-11 wsl lunar neovim {}", add_one(x));
    println!("how error handling is in rust?");
}

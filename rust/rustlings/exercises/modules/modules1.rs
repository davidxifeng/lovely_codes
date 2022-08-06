// modules1.rs
// Execute `rustlings hint modules1` or use the `hint` watch subcommand for a hint.

// 同一个源文件可以有多个mod?还挺方便的
mod sausage_factory {
    // Don't let anybody outside of this module see this!
    fn get_secret_recipe() -> String {
        String::from("Ginger")
    }

    pub fn make_sausage() {
        get_secret_recipe();
        println!("sausage!");
    }
}

mod demo {
    pub fn say_hi() {
        // 宏可以不加;号
        println!("hi")
    }
}

fn main() {
    sausage_factory::make_sausage();
    demo::say_hi();
}

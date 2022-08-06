// traits5.rs
//
// Your task is to replace the '??' sections so the code compiles.
// Don't change any line other than 27.
// Execute `rustlings hint traits5` or use the `hint` watch subcommand for a hint.

pub trait SomeTrait {
    fn some_function(&self) -> bool {
        true
    }
}

pub trait OtherTrait {
    fn other_function(&self) -> bool {
        true
    }
}

struct SomeStruct {
    name: String,
}

impl SomeTrait for SomeStruct {}
impl OtherTrait for SomeStruct {}

// + 多个接口
fn some_func(item: impl SomeTrait + OtherTrait) -> bool {
    item.some_function() && item.other_function()
}

fn main() {}

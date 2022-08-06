// options3.rs
// Execute `rustlings hint options3` or use the `hint` watch subcommand for a hint.

struct Point {
    x: i32,
    y: i32,
}

fn main() {
    // 推测自然是只有堆上对象才需要如此处理
    let y: Option<Point> = Some(Point { x: 100, y: 200 });

    match y {
        // 使用ref表示仅借用,不移动; 不影响一个值是否匹配,只影响匹配方式: 借用还是move
        Some(ref p) => println!("Co-ordinates are {},{} ", p.x, p.y),
        _ => println!("no match"),
    }
    y; // Fix without deleting this line.
}

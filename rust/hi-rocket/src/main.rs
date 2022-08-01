#[macro_use] extern crate rocket;

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

// 2022/8/2
// using with cargo watch to auto compile & restart
// 3.73s

#[get("/hi/<name>")]
fn hi(name: &str) -> String {
    format!("hello, {}", name)
}


#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![
                          index,
                          hi,
    ])
}

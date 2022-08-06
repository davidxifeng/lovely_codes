// iterators4.rs
// Execute `rustlings hint iterators4` or use the `hint` watch subcommand for a hint.

pub fn factorial(num: u64) -> u64 {
    // method 1

    // let mut r = 1;
    // for i in 1 .. num + 1{
    //     r *= i
    // }
    // r

    // method 2, 直接使用标准库中的product,只是不明白为何会有这个函数
    // (1..num+1).product()

    // 语法(糖): range notation a..b

    // 脱糖后的语法:  Overloadable operators.
    // assert_eq!((3..5), std::ops::Range { start: 3, end: 5 });
    // 运算符重载, 甚至不算是编译器的语法糖. 运算符重载的约束: backed by特性的才可以.
    // 比如赋值 = 运算符就不可以重载. (感觉比C++中的好~)

    // assert_eq!((3..=5), std::ops::RangeInclusive::new(3, 5));

    // a..=b can be used for a range that is inclusive on both ends.
    (1..=num).product()

    // Complete this function to return the factorial of num
    // Do not use:
    // - return
    // Try not to use:
    // - imperative style loops (for, while)
    // - additional variables
    // For an extra challenge, don't use:
    // - recursion
    // Execute `rustlings hint iterators4` for hints.
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn factorial_of_0() {
        assert_eq!(1, factorial(0));
    }

    #[test]
    fn factorial_of_1() {
        assert_eq!(1, factorial(1));
    }
    #[test]
    fn factorial_of_2() {
        assert_eq!(2, factorial(2));
    }

    #[test]
    fn factorial_of_4() {
        assert_eq!(24, factorial(4));
    }
}

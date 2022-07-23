package demo

import (
	"testing"
)

func TestTwoSum(t *testing.T) {

	fn := func(nums []int, target int) {
		index := TwoSum(nums, target)
		index2 := TwoSumSimple(nums, target)
		if len(index) != 2 || len(index2) != 2 {
			t.Fail()
		}
		a, b := nums[index[0]], nums[index[1]]
		if a == b || a+b != target {
			t.Fail()
		}
	}

	fn([]int{2, 7, 11, 15}, 9)
	fn([]int{3, 2, 4}, 6)
	fn([]int{6, 5, 4}, 10)
}

func TestAddTwoNumbers(t *testing.T) {
	testAbs := func(n, v int) {
		if AbsIf(n) != AbsBitwise(n) {
			t.Fail()
		}
	}
	testAbs(25, 25)
	testAbs(0, 0)
	testAbs(9223372036854775807, 9223372036854775807)
	testAbs(-9223372036854775807, 9223372036854775807)
	testAbs(-9223372036854775808, -9223372036854775808)
	testAbs(-52, 52)

	testList := func(n int) {
		if ListToNum(NumToList(n)) != n {
			t.Fail()
		}
	}
	testList(123)
	testList(1)
	testList(0)
	testList(123456789)
	testList(123450006789)
	testList(1234500067890)

	testFn := func(a, b int) {
		c := ListToNum(AddTwoNumbers(NumToList(a), NumToList(b)))
		if c != a+b {
			t.Fail()
		}
	}
	testFn(1, 23)
	testFn(10, 235)
	testFn(9999, 2)
}

func TestLengthOfLongestSubstring(t *testing.T) {
	fn := func(s string, n int) {
		if LengthOfLongestSubstring(s) != n {
			t.Fail()
		}
	}
	fn("bbb", 1)
	fn("abcabcbb", 3)
	fn("pwwkew", 3)
	fn("dvdf", 3)
	fn("abba", 2)
}

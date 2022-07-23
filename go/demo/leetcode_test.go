package demo

import (
	"testing"
)

func twoSum(nums []int, target int) []int {
	dict := make(map[int]int, len(nums))

	for i, v := range nums {
		idx, has := dict[target-v]
		if has {
			return []int{idx, i}
		}
		dict[v] = i
	}
	return nil
}

func twoSumSimple(nums []int, target int) []int {
	startWith := 0
	n := len(nums)

do_again:
	a := nums[startWith]
	for i := startWith + 1; i < n; i++ {
		if a+nums[i] == target {
			return []int{startWith, i}
		}
	}

	if startWith < n {
		startWith += 1
		goto do_again
	}
	// never here
	return nil
}

func TestTwoSum(t *testing.T) {

	fn := func(nums []int, target int) {
		index := twoSum(nums, target)
		index2 := twoSumSimple(nums, target)
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

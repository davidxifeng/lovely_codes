package demo

import (
	"testing"
)

func twoSum(nums []int, target int) []int {
	return []int{}
}

func TestTwoSum(t *testing.T) {
	nums := []int{2, 7, 11, 15}
	target := 9

	index := twoSum(nums, target)
	if len(index) != 2 {
		t.Fail()
	}
	a, b := nums[index[0]], nums[index[1]]
	if a+b != target {
		t.Fail()
	}
}

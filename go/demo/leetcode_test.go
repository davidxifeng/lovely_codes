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

type ListNode struct {
	Val  int
	Next *ListNode
}

/*
You are given two non-empty linked lists representing two non-negative integers.
The digits are stored in reverse order, and each of their nodes contains a single digit.
Add the two numbers and return the sum as a linked list.

You may assume the two numbers do not contain any leading zero, except the number 0 itself.
*/
func addTwoNumbers(l1 *ListNode, l2 *ListNode) *ListNode {
	carry := 0
	head := &ListNode{}
	prev := head
	for l1 != nil && l2 != nil {
		n := l1.Val + l2.Val + carry
		if n > 9 {
			n = n - 10
			carry = 1
		} else {
			carry = 0
		}
		prev.Val = n
		prev.Next = &ListNode{}
		prev = prev.Next

		l1 = l1.Next
		l2 = l2.Next
	}
	var left *ListNode
	if l1 != nil {
		left = l1
	} else if l2 != nil {
		left = l2
	} else {
		left = nil
	}

	for ; left != nil; left = left.Next {
		n := carry + left.Val
		if n > 9 {
			n = n - 10
			carry = 1
		} else {
			carry = 0
		}
		prev.Val = n
		prev.Next = &ListNode{}
	}
	if carry != 0 {
		prev.Val = 1
		prev.Next = nil
	}

	return head
}

func mkLinkList(vals []int) *ListNode {
	head := &ListNode{
		Val:  vals[0],
		Next: nil,
	}

	for i, prev := 1, head; i < len(vals); i++ {
		curr := &ListNode{
			Val:  vals[i],
			Next: nil,
		}
		prev.Next = curr
		prev = curr
	}
	return head
}

func listToNum(l *ListNode) (r int) {
	for i := 1; l != nil; l = l.Next {
		r += l.Val * i
		i *= 10
	}
	return r
}

func TestAddTwoNumbers(t *testing.T) {
	l1 := mkLinkList([]int{2, 4, 3})
	l2 := mkLinkList([]int{5, 6, 4})
	r := addTwoNumbers(l1, l2)
	n := listToNum(r)
	if n != 807 {
		t.Fail()
	}
}

package demo

import "math/bits"

func TwoSum(nums []int, target int) []int {
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

func TwoSumSimple(nums []int, target int) []int {
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
func AddTwoNumbers(l1 *ListNode, l2 *ListNode) *ListNode {
	carry := 0
	var head *ListNode = nil
	prev := head
	if l1 == nil || l2 == nil {
		return nil
	}

	{
		n := l1.Val + l2.Val + carry
		if n > 9 {
			n = n - 10
			carry = 1
		} else {
			carry = 0
		}
		head = &ListNode{
			Val:  n,
			Next: nil,
		}
		l1, l2, prev = l1.Next, l2.Next, head
	}

	for l1 != nil && l2 != nil {
		n := l1.Val + l2.Val + carry
		if n > 9 {
			n = n - 10
			carry = 1
		} else {
			carry = 0
		}
		prev.Next = &ListNode{
			Val:  n,
			Next: nil,
		}
		prev = prev.Next
		l1, l2 = l1.Next, l2.Next
	}

	var remain *ListNode
	if l1 != nil {
		remain = l1
	} else if l2 != nil {
		remain = l2
	} else {
		remain = nil
	}

	for ; remain != nil; remain = remain.Next {
		n := carry + remain.Val
		if n > 9 {
			n = n - 10
			carry = 1
		} else {
			carry = 0
		}
		prev.Next = &ListNode{
			Val:  n,
			Next: nil,
		}
		prev = prev.Next
	}
	if carry != 0 {
		prev.Next = &ListNode{
			Val:  1,
			Next: nil,
		}
	}

	return head
}

func ListToNum(l *ListNode) (r int) {
	for i := 1; l != nil; l = l.Next {
		r += l.Val * i
		i *= 10
	}
	return r
}

func AbsBitwise(n int) int {
	x := n >> (bits.UintSize - 1)
	return (n ^ x) - x
}
func AbsIf(n int) int {
	if n < 0 {
		return -n
	} else {
		return n
	}
}

func NumToList(n int) *ListNode {
	n = AbsBitwise(n)
	head := &ListNode{}
	prev := head

	for n > 0 {
		prev.Val = n % 10
		n = n / 10
		prev.Next = &ListNode{}
		prev = prev.Next
	}

	return head
}
package demo

import (
	"math/bits"
	"unicode/utf8"

	"golang.org/x/exp/constraints"
)

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

func Max[T constraints.Ordered](a, b T) T {
	if a < b {
		return b
	}
	return a
}
func Min[T constraints.Ordered](a, b T) T {
	if a > b {
		return b
	}
	return a
}

func LengthOfLongestSubstring(s string) int {
	sl := utf8.RuneCountInString(s)
	vs := []rune(s)
	dict := make(map[rune]int, sl)
	max := 0

	left := 0
	for right := 0; right < sl; right++ {
		v := vs[right]

		if last, has := dict[v]; has {
			left = Max(left, last+1)
			dict[v] = right
		} else {
			dict[v] = right
		}

		max = Max(max, right-left+1)
		if max > sl-left+1 {
			break
		}
	}
	return max
}

func FindMedianSortedArrays(nums1 []int, nums2 []int) float64 {
	l1, l2 := len(nums1), len(nums2)
	l := l1 + l2

	prev, curr := 0, 0

	for i, j, k := 0, 0, 0; k <= l/2; k++ {
		if i < l1 && j < l2 {
			if nums1[i] < nums2[j] {
				prev = curr
				curr = nums1[i]
				i++
			} else {
				prev = curr
				curr = nums2[j]
				j++
			}
		} else if i == l1 {
			prev = curr
			curr = nums2[j]
			j++
		} else if j == l2 {
			prev = curr
			curr = nums1[i]
			i++
		}
	}
	if l%2 == 0 {
		return float64((prev + curr)) / 2
	} else {
		return float64(curr)
	}

}

func IsPalindrome(s string) bool {
	// 输入只包括 字母和数字,所以直接使用byte
	l := len(s)
	m := l / 2
	for i := 0; i <= m; i++ {
		if s[i] != s[l-i-1] {
			return false
		}
	}
	return true
}

func LongestPalindrome(s string) string {
	// 暴力搜索, 时间复杂度 O(n ^ 3), 空间复杂度O(1)
	// 官方给出了另外4种更高效的算法
	l := len(s)
	if l < 1 {
		return ""
	}

	for i := l; i > 1; i-- {
		for a, b := 0, 0+i; b <= l; a, b = a+1, b+1 {
			if IsPalindrome(s[a:b]) {
				return s[a:b]
			}
		}
	}
	return s[0:1]
}

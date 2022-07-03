package demo

import (
	"fmt"

	"testing"
)

var pc [256]byte

func init() {
	for i := range pc {
		pc[i] = pc[i/2] + byte(i&1)
	}
}

func PopCount(x uint64) int {
	return int(pc[byte(x>>0)] +
		pc[byte(x>>(1*8))] +
		pc[byte(x>>(2*8))] +
		pc[byte(x>>(3*8))] +
		pc[byte(x>>(4*8))] +
		pc[byte(x>>(5*8))] +
		pc[byte(x>>(6*8))] +
		pc[byte(x>>(7*8))])
}

func PopCount2(x uint64) (c int) {
	for ; x != 0; c += 1 {
		x &= (x - 1)
	}
	return c
}

func TestPopCount(t *testing.T) {
	fn := func(x uint64) {
		fmt.Println(x, ` pop count is `, PopCount(x), " , ", PopCount2(x))
	}
	fn(11)
	var c uint64 = 0
	c -= 1
	fn(c)
	fn(520)
}

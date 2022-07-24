package cmd

import (
	"fmt"
	"play/demo"
	"unicode/utf8"

	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(demoCmd)
}

var demoCmd = &cobra.Command{
	Use:   "demo",
	Short: "run demo",
	Run: func(cmd *cobra.Command, args []string) {
		demoMain()
	},
}

func demoMain() {
	s := "中文🏄💾"
	for i, v := range s {
		fmt.Printf("%d %c %v 0x%05X\n", i, v, v, v)
	}
	fmt.Println("len s : ", len(s), utf8.RuneCountInString(s))

	fmt.Println(demo.LongestPalindrome("abcba"))
}

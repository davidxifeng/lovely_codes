package cmd

import (
	"fmt"
	"play/demo"

	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(demoCmd)
}

var demoCmd = &cobra.Command{
	Use:   "demo",
	Short: "🏄💾run demo",
	Long:  "测试LeetCode等代码",
	Run: func(cmd *cobra.Command, args []string) {
		demoMain()
	},
}

// utf8.RuneCountInString("Hi")

func demoMain() {
	r := demo.Convert("PAYPALISHIRING", 3)
	fmt.Println(r == "PAHNAPLSIIGYIR", r)
}

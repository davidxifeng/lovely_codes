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
	Short: "run demo",
	Run: func(cmd *cobra.Command, args []string) {
		demoMain()
	},
}

func demoMain() {
	fmt.Println("abs ", demo.AbsIf(-2), demo.AbsBitwise(-2))
	fmt.Println("abs ", demo.AbsIf(-9223372036854775808), demo.AbsBitwise(-9223372036854775808))
	fmt.Println("abs ", demo.AbsIf(-9223372036854775807), demo.AbsBitwise(9223372036854775807))
}

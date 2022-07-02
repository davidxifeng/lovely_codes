package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

func init() {
	cobra.OnInitialize(initConfig)
}

func initConfig() {
	viper.SetConfigName("play")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")
}

var rootCmd = &cobra.Command{
	Use:   "play",
	Short: "playground for go learning",
	Long: `Learning The Go Programming Language
                love by david.`,
	Version: "0.1.0",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("hello root cmd")
	},
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(0)
	}
}

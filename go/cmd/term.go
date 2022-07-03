package cmd

import (
	"github.com/rivo/tview"
	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(cuiCmd)
}

var cuiCmd = &cobra.Command{
	Use:   "tview",
	Short: "run tview demo",
	Run: func(cmd *cobra.Command, args []string) {
		cuiMain()
	},
}

func cuiMain() {
	app := tview.NewApplication()

	button := tview.NewButton("Bye").
		SetSelectedFunc(func() {
			app.Stop()
		})

	button.SetBorder(true).SetRect(10, 10, 20, 5)

	box := tview.NewBox().
		SetBorder(true).
		SetTitle("Hello, world!")

	flex := tview.NewFlex().
		AddItem(box, 0, 1, false).
		AddItem(button, 20, 1, true)

	app.SetRoot(flex, true).
		EnableMouse(true)

	if err := app.Run(); err != nil {
		panic(err)
	}
}

package cmd

import (
	"log"

	"github.com/panjf2000/gnet"
	"github.com/spf13/cobra"
)

func init() {
	rootCmd.AddCommand(echoCmd)
}

var echoCmd = &cobra.Command{
	Use:   "echo",
	Short: "run echo",
	Run: func(cmd *cobra.Command, args []string) {

		echo := new(echoServer)

		log.Println("listening on TCP 9000")
		log.Fatal(gnet.Serve(echo, "tcp://:9000", gnet.WithMulticore(true)))
	},
}

type echoServer struct {
	*gnet.EventServer
}

func (es *echoServer) React(frame []byte, c gnet.Conn) (out []byte, action gnet.Action) {
	out = frame
	return
}

// +build windows

package main

import (
	"flag"
	"fmt"
	"os"
)

func main() {
	var mode string
	var spawn bool
	var v bool
	flag.StringVar(&mode, "mode", "", "mode")
	flag.BoolVar(&spawn, "spawn", false, "spawn")
	flag.BoolVar(&v, "version", false, "get sudo version")
	flag.Parse()

	args := flag.Args()
	if v {
		fmt.Printf("sudo version %s\n", Version)
		os.Exit(0)
	}

	if mode != "" {
		os.Exit(client(mode, args))
	}
	if spawn {
		if flag.NArg() == 0 {
			args = []string{"cmd"}
		}
		os.Exit(start(args))
	}
	if flag.NArg() == 0 {
		args = []string{"cmd", "/c", "start"}
	}
	os.Exit(server(args))
}

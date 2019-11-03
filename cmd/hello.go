package main

import (
	"fmt"
	"os"

	"github.com/hjhurtado/testing-circleci/teller"
)

func main() {

	var name string

	if len(os.Args) > 1 {
		name = os.Args[1]
	}

	if out, err := teller.SayHello(name); err == nil {
		fmt.Fprintln(os.Stdout, out)
	} else {
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(1)
	}

}

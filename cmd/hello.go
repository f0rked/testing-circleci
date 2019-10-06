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

	fmt.Println(teller.SayHello(name))

}

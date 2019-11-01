package teller

import "fmt"

// SayHello creates a personalyzed greeting message
func SayHello(name string) string {

	if name == "" {
		name = "Visitor"
	}

	return fmt.Sprintf("Hello %s!!", name)
}

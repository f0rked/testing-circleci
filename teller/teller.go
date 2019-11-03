package teller

import (
	"errors"
	"fmt"
	"regexp"
)

// SayHello creates a personalyzed greeting message
func SayHello(name string) (string, error) {
	r := regexp.MustCompile("^[a-zA-Z0-9]*$")

	if name == "" {
		name = "Visitor"
	} else if !r.MatchString(name) {
		return "", errors.New("Invalid name")
	}

	return fmt.Sprintf("Hello %s!!", name), nil
}

package teller_test

import (
	"testing"

	"github.com/hjhurtado/testing-circleci/teller"
)

func TestSayHelloEmptyParam(t *testing.T) {
	expected := "Hello Visitor!!"
	name := ""

	if value := teller.SayHello(name); value != expected {
		t.Errorf("Error: expected %q, got %q", expected, value)
	}
}

func TestSayHelloWithRealParam(t *testing.T) {
	expected := "Hello Héctor!!"
	name := "Héctor"

	if value := teller.SayHello(name); value != expected {
		t.Errorf("Error: expected %q, got %q", expected, value)
	}
}

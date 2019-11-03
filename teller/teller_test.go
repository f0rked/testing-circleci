package teller_test

import (
	"testing"

	"github.com/hjhurtado/testing-circleci/teller"
)

func TestSayHelloEmptyParam(t *testing.T) {
	expected := "Hello Visitor!!"
	name := ""

	if value, _ := teller.SayHello(name); value != expected {
		t.Errorf("Error: expected %q, got %q", expected, value)
	}
}

func TestSayHelloWithRealParam(t *testing.T) {
	expected := "Hello Hector!!"
	name := "Hector"

	if value, _ := teller.SayHello(name); value != expected {
		t.Errorf("Error: expected %q, got %q", expected, value)
	}
}

func TestSayHelloFailsWithNonAlphanumericCharacters(t *testing.T) {
	testCases := []string{"Met:ro", "Güete", "Mílter"}

	for _, c := range testCases {
		if value, err := teller.SayHello(c); err == nil {
			t.Errorf("Expected error but no error returned. Value %q", value)
		}
	}
}

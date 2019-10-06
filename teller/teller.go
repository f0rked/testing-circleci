package teller

// SayHello creates a personalyzed greeting message
func SayHello(name string) string {

	if name == "" {
		name = "Visitor"
	}

	return "Hello " + name + "!!"
}

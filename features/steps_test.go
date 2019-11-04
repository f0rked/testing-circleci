//nolint:
package main

import (
	"fmt"
	"os"
	"os/exec"

	"github.com/DATA-DOG/godog"
)

func (c *testContext) iInvokeHelloWithParameter(parameter string) (err error) {
	cmd := exec.Command(c.helloBinary, parameter)
	if output, e := cmd.Output(); e != nil {
		if ee, ok := e.(*exec.ExitError); ok {
			c.retcode = ee.ExitCode()
			c.stdErr = string(ee.Stderr[:len(ee.Stderr)-1])
		}
	} else {
		c.stdOut = string(output[:len(output)-1])
	}

	return
}

func (c *testContext) iGetAsErrorCode(errCode int) (err error) {
	if c.retcode != errCode {
		err = fmt.Errorf("Error code mismatch: Expected %q; got %q", errCode, c.retcode)
	}

	return
}

func (c *testContext) iGetAsOutputText(text string) (err error) {
	if c.stdOut != text {
		err = fmt.Errorf("Output mismatch: Expected %q; got %q", text, c.stdOut)
	}

	return
}

func (c *testContext) iGetAsErrorText(text string) (err error) {
	if c.stdErr != text {
		err = fmt.Errorf("Error mesage mismatch: Expected %q; got %q", text, c.stdErr)
	}

	return
}

type testContext struct {
	helloBinary    string
	retcode        int
	stdErr, stdOut string
}

func FeatureContext(s *godog.Suite) {
	ctx := &testContext{}

	ctx.helloBinary = os.Getenv("HELLO_BINARY")
	if ctx.helloBinary == "" {
		ctx.helloBinary = "../output/hello"
	}

	s.Step(`^I invoke hello with parameter "([^"]*)"$`, ctx.iInvokeHelloWithParameter)
	s.Step(`^I get (\d+) as error code$`, ctx.iGetAsErrorCode)
	s.Step(`^I get "([^"]*)" as output text$`, ctx.iGetAsOutputText)
	s.Step(`^I get "([^"]*)" as error text$`, ctx.iGetAsErrorText)
}

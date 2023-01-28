package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"
)

func main() {

	arg := os.Args[1]

	cmd := exec.Command("windscribe", arg)

	stdout, err := cmd.Output()
	connected := false
	result := "%{F#8be9fd}%{F-} "

	if (!strings.Contains(string(stdout), "DISCONNECTED") && strings.Contains(string(stdout), "CONNECTED")) || strings.Contains(string(stdout), "Your IP changed") {
		connected = true
	}
	if err != nil {
		fmt.Println(err.Error())
		return
	}

	if connected == true {
		time.Sleep(3 * time.Second)
		info := exec.Command("windscribe", "account")
		stdout, _ := info.Output()
		lines := strings.Split(string(stdout), "\n")
		for i, line := range lines {
			if i == 2 {
				line := strings.Replace(line, "Data Usage: ", "", -1)
				result = "%{F#50fa7b}%{F-} " + strings.Replace(line, " / 10 GB", "", -1)
			}
		}
	}
	fmt.Println(result)
}

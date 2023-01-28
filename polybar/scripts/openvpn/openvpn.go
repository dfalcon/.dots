package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func main() {

	result := "%{F#8be9fd}VPN%{F-}"
	if len(os.Args) < 2 {
		cmd := exec.Command("pgrep", "-a", "openvpn")
		stdout, _ := cmd.Output()
		// fmt.Println(string(stdout))
		if strings.Contains(string(stdout), "nm-openvpn-service") {

			result = "%{F#50fa7b}VPN%{F-}"
		}

	} else {
		action := os.Args[1]

		cmd := exec.Command("nmcli", "connection", action, "dfalcon")
		cmd.Output()
	}

	fmt.Println(result)
}

package main

import (
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

func main() {
	cmd := exec.Command("playerctl", "--player=spotify", "volume")
	output, _ := cmd.Output()
	volume, _ := strconv.ParseFloat(strings.TrimSpace(string(output)), 64)

	if len(os.Args) < 2 {
		cmd := exec.Command("playerctl", "--player=spotify", "metadata", "artist")
		stdout, _ := cmd.Output()
		artist := string(stdout)
		cmd = exec.Command("playerctl", "--player=spotify", "metadata", "title")
		stdout, _ = cmd.Output()
		title := string(stdout)
		result := strings.Replace(artist+" - "+title, "\n", "", -1)
		if len(result) > 100 {
			fmt.Println(result[0:100] + "...")
		} else {
			fmt.Println(result)
		}

	} else {
		action := os.Args[1]
		switch action {
		case "next":
			cmd = exec.Command("playerctl", "--player=spotify", action)
			cmd.Output()
		case "previous":
			cmd = exec.Command("playerctl", "--player=spotify", action)
			cmd.Output()
		case "play-pause":
			cmd = exec.Command("playerctl", "--player=spotify", action)
			cmd.Output()
		case "volume-up":
			volume = volume + 0.05
			volumeStr := fmt.Sprintf("%f", volume)
			cmd = exec.Command("playerctl", "--player=spotify", "volume", volumeStr)
			cmd.Output()
		case "volume-down":
			volume = volume - 0.05
			volumeStr := fmt.Sprintf("%f", volume)
			cmd = exec.Command("playerctl", "--player=spotify", "volume", volumeStr)
			cmd.Output()

		default:
			return
		}
	}
}

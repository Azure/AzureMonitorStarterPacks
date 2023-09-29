package main

import (
	"encoding/csv"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// A function that runs a PowerShell command and returns the output as a string
func runPowerShell(cmd string) string {
	out, err := exec.Command("powershell", "-Command", cmd).Output()
	if err != nil {
		fmt.Println(err)
		return ""
	}
	return string(out)
}

// A function that parses the output of Get-WindowsFeature and returns a slice of installed roles
func getRoles() []string {
	cmd := "$features=Get-WindowsFeature | Where-Object {$_.InstallState -eq 'Installed'} | Select-Object Name, DisplayName, FeatureType, Depth | foreach { "$runTime $($_.Name),$($_.DisplayName),$($_.FeatureType),$($_.Depth)" } "
	out := runPowerShell(cmd)
	lines := strings.Split(out, "\r\n")
	roles := make([]string, 0, len(lines))
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line != "" {
			roles = append(roles, line)
		}
	}
	return roles
}

// A function that parses the output of Get-AppxPackage and returns a slice of installed applications
func getApps() []string {
	cmd := "Get-WmiObject -Class Win32_Product | Select-Object Name, Vendor, Caption | foreach {"$runTime $($_.Name),$($_.Vendor),$($_.Caption)"}"
	out := runPowerShell(cmd)
	lines := strings.Split(out, "\r\n")
	apps := make([]string, 0, len(lines))
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line != "" {
			apps = append(apps, line)
		}
	}
	return apps
}

// A function that writes the roles and applications to a csv file
func writeCSV(roles []string, apps []string) {
	file, err := os.Create("roles_apps.csv")
	if err != nil {
		fmt.Println(err)
		return
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	writer.Write([]string{"Roles", "Applications"}) // Write the header row

	maxLen := len(roles)
	if len(apps) > maxLen {
		maxLen = len(apps)
	}

	for i := 0; i < maxLen; i++ {
		row := make([]string, 2)
		if i < len(roles) {
			row[0] = roles[i]
		}
		if i < len(apps) {
			row[1] = apps[i]
		}
		writer.Write(row) // Write each row
	}
}

func main() {
	roles := getRoles()
	fmt.Println("Installed roles:", roles)

	apps := getApps()
	fmt.Println("Installed applications:", apps)

	writeCSV(roles, apps)
	// fmt.Println("CSV file created: roles_apps.csv")
}
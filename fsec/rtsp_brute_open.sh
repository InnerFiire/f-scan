#!/bin/bash

# Capture the primary network interface
#interface=$(route -n | grep 'UG[ \t]' | awk '{print $8}')

# Capture the IP address associated with the interface
ip=$(ifconfig 2>/dev/null | awk '/wlan0/{f=1} f && /inet /{print $2; exit}' | sed -E 's/[0-9]+$/1\/24/')

# Run nmap to scan for open ports and extract the IP addresses
result=$(nmap $ip -p554 --open -Pn -sT | grep -oE "([0-9]{1,3}[.]){3}[0-9]{1,3}")
echo "${result}"
# Iterate over each IP address found
for target_ip in $result; do
    # Read each line from routes.txt and test it
    while IFS= read -r line; do
        # Print a header for the current test
        printf "\n================TESTING================\n"

        # Construct the RTSP URL
        rtsp_url="rtsp://admin:@$target_ip:554$line"

        # Echo the URL for logging
        echo -e $rtsp_url

        # Run mpv to test the RTSP stream
        mpv $rtsp_url --no-audio --no-video

        # Print a separator for readability
        printf "\n\n"
    done < routes.txt
done

# Echo all IPs found (optional)
echo "IPs found: ${result}"

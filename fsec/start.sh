#!/usr/bin/env bash
# F - Security: portable security audit tool launcher

set -u

# Always run from the script's own directory so relative paths work
cd "$(dirname "$0")" || {
  echo "Failed to enter script directory."
  exit 1
}

# Colors (fallback if terminal doesn't support)
if tput setaf 1 >/dev/null 2>&1; then
  BOLD="$(tput bold)"
  RESET="$(tput sgr0)"
else
  BOLD=""
  RESET=""
fi

cat << "EOF"
___________             _________                          .__  __
\_   _____/            /   _____/ ____   ____  __ _________|__|/  |_ ___.__.
 |    __)     ______   \_____  \_/ __ \_/ ___\|  |  \_  __ \  \   __<   |  |
 |     \     /_____/   /        \  ___/\  \___|  |  /|  | \/  ||  |  \___  |
 \___  /              /_______  /\___  >\___  >____/ |__|  |__||__|  / ____|
     \/                       \/     \/     \/                       \/
EOF
echo
echo "                         Fast - Security"
echo "              Your Portable Security Audit Tool."
echo
ip=$(ifconfig 2>/dev/null | awk '/wlan0/{f=1} f && /inet /{print $2; exit}' | sed -E 's/[0-9]+$/1\/24/')
echo 'Your Current Network Is:' $ip
echo

menu() {
  echo "Here are the scripts:"
  echo "  1) crackmap.sh        - Run crackmapexec on current network"
  echo "  2) fscan.sh           - Run fscan on current network"
  echo "  3) nmap.sh            - Run nmap on current network"
  echo "  4) auto_ingram.sh     - Run Webcam autoexploit script on current network"
  echo "  5) rtsp_brute_open.sh - Run RTSP bruteforce on current network"
  echo "  6) nuclei.sh          - Run Nuclei on current network"
  echo "  7) autorecon.sh       - Run Autorecon (only TCP) on current network"
  echo "  0) Exit"
  echo
}

run_script() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Error: '$file' not found in $(pwd)."
    return 1
  fi
  if [[ ! -x "$file" ]]; then
    # try to make it executable; if it fails, run via bash
    chmod +x "$file" 2>/dev/null || true
  fi

  echo
  echo "=== Running: $file ==="
  echo

  # Prefer executing directly if executable; else run with bash
  if [[ -x "$file" ]]; then
    "./$file"
  else
    bash "./$file"
  fi

  local status=$?
  echo
  echo "=== Script '$file' finished with exit code ${status} ==="
  echo
  return $status
}

# Handle Ctrl+C gracefully
trap 'echo; echo "Exiting..."; exit 0' INT

while true; do
  menu
  read -rp "Choose an option [0-7]: " choice
  case "$choice" in
    1) run_script "crackmap.sh" ;;
    2) run_script "fscan.sh" ;;
    3) run_script "nmap.sh" ;;
    4) run_script "Ingram/auto_ingramv2.sh" ;;
    5) run_script "rtsp_brute_open.sh" ;;
    6) run_script "nuclei.sh" ;;
	7) run_script "autorecon.sh" ;;
    0) echo "Goodbye!"; exit 0 ;;
    *) echo "Invalid choice. Please enter a number from 0 to 7." ;;
  esac

  # Pause before showing menu again
  read -rp "Press Enter to return to the menu..." _
done

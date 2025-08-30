#!/bin/bash
# Fast /24 ping sweep that auto-detects the wlan0 subnet, runs in parallel,
# and exits cleanly on Ctrl-C while keeping results. After scan, runs autorecon
# on all alive hosts.


#For non root devices: remove osscan at all scripts here: root/.local/share/AutoRecon/plugins/
#And append -sT flag at default config file nmap scan



# ---- Configurable options ----
iface="${1:-wlan0}"        # pass interface as first arg; defaults to wlan0
max_jobs="${MAX_JOBS:-50}" # max concurrent pings (env var MAX_JOBS overrides)
timeout_s=1                # ping timeout per host (seconds)
outfile=""                 # set automatically below
# ------------------------------

# Get "X.Y.Z.1/24" from the chosen interface (based on your one-liner)
cidr="$(ifconfig 2>/dev/null \
  | awk '/'"$iface"'/ {f=1} f && /inet /{print $2; exit}' \
  | sed -E 's/[0-9]+$/1\/24/')"

if [[ -z "$cidr" ]]; then
  echo "Error: could not determine IPv4 for interface '$iface' via ifconfig."
  echo "Tip: ensure the interface is up and has an IPv4 address."
  exit 1
fi

# Extract "X.Y.Z" from "X.Y.Z.1/24"
network="${cidr%.*/*}"

# Output file (include network in filename)
outfile="alive_${network//./-}.txt"
: > "$outfile"  # clear file

# Simple file lock (for safe concurrent writes)
lockfile="${outfile}.lock"
touch "$lockfile"

# Cleanup function
cleanup() {
  rm -f "$lockfile"
}
trap cleanup EXIT

# Handle Ctrl-C: stop background jobs, wait, and exit gracefully
on_int() {
  echo
  echo "Ctrl-C received: stopping scan…"
  # Kill any background pings
  jobs -p | xargs -r kill 2>/dev/null
  wait
  echo "Partial results saved in $outfile"
  echo "Skipping autorecon because scan was interrupted."
  exit 130
}
trap on_int INT

# Ping one host and record if alive
scan_host() {
  local ip="$1"
  if ping -c 1 -W "$timeout_s" "$ip" > /dev/null 2>&1; then
    echo "$ip is alive"
    {
      exec 9>"$lockfile"
      flock -x 9
      echo "$ip" >> "$outfile"
      flock -u 9
      exec 9>&-
    } 2>/dev/null
  fi
}

echo "Scanning ${network}.1–${network}.254 on interface ${iface} with up to ${max_jobs} parallel pings…"
echo "Press Ctrl-C to stop early (results are saved incrementally)."

# Launch pings in parallel with concurrency limiter
for i in {1..254}; do
  ip="${network}.${i}"
  scan_host "$ip" &
  while (( $(jobs -r | wc -l) >= max_jobs )); do
    sleep 0.05
  done
done

wait

echo "Scan complete. Alive hosts saved in $outfile"

# Run autorecon against all alive hosts
if [[ -s "$outfile" ]]; then
  echo "Starting autorecon scan on hosts from $outfile …"
  autorecon -t "$outfile"
else
  echo "No alive hosts found. Skipping autorecon."
fi

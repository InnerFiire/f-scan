#!/bin/bash
ip=$(ifconfig 2>/dev/null | awk '/wlan0/{f=1} f && /inet /{print $2; exit}' | sed -E 's/[0-9]+$/1\/24/')
echo $ip
./fscan -h $ip

# F-Security  
**Your Portable Security Audit Tool** 🔐  

> **F-Security** is a portable security auditing toolkit designed for **Android devices** using **Termux** with **Rootless NetHunter**.  
> It provides a simple bash-driven menu (`start.sh`) to launch a variety of network scanning and exploitation tools in one place.  
>For non root devices: remove osscan at all scripts here: root/.local/share/AutoRecon/plugins/
>and append -sT flag at default config autorecon file nmap scan
---

## 🚀 Features  
- Runs directly on your Android device (Termux / NetHunter)  
- Automatically detects your local network  
- Menu-driven interface to run multiple tools:
  - `crackmapexec` → SMB / RDP / WinRM enumeration  
  - `fscan` → Fast internal network scanner  
  - `nmap` → Advanced network scanning  
  - `auto_ingram.sh` → Webcam auto-exploit tool
  - `rtsp_brute_open.sh` → RTSP brute-force attack  
  - `nuclei` → Vulnerability scanning  
  - `autorecon` → Automated service enumeration (TCP only)  

---

## 📥 Installation  

> ⚠️ **Important**: Requires Termux or Rootless NetHunter on Android.

Install dependencies (tools used by F-Security):

```bash
pkg install -y git curl wget python python-pip golang nmap

pip install crackmapexec
git clone https://github.com/shadow1ng/fscan.git
cd fscan
go build
mv fscan /data/data/com.termux/files/usr/bin/
cd ..
pip install git+https://github.com/Tib3rius/AutoRecon.git
git clone https://github.com/jorhelp/Ingram.git
```

## Usage
bash start.sh

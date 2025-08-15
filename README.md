# WebPen3

WebPen3 is a web penetration testing automation tool.  
It helps perform subdomain and directory scanning with multi-threading and a simple command-line interface.

---

## Installation

### Quick Install (via web)
```bash
curl -sL https://raw.githubusercontent.com/erbiseynqzi/WebPen3/main/install.sh | bash
```

### Manual Install
```bash
git clone https://github.com/erbiseynqzi/WebPen3.git
cd WebPen3
chmod +x install.sh webpen3.sh
./install.sh
```

> **Notes:**  
> - `chmod +x` ensures the scripts are executable.  
> - The installer automatically updates your `PATH` for the current session, so you can run `webpen3` immediately.  
> - PATH is also added to `.bashrc` for future terminal sessions.

---

## Usage
After installation, run the tool with:
```bash
webpen3
```
Or, if running from the local folder without installation:
```bash
./webpen3.sh
```
The tool will ask for:
- Target domain
- Subdomain wordlist path
- Directory wordlist path
- Thread counts for scans
- Output file for results

---

## License
MIT License

---

## Disclaimer
This tool is intended for educational and authorized penetration testing only.  
The author is not responsible for any misuse or damage caused by this tool.

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
chmod +x install.sh
./install.sh
```

---

## Usage
After installation, run the tool with:
```bash
webpen3
```
Or, if running from the local folder:
```bash
chmod +x webpen3.sh
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

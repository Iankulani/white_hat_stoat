<img width="1536" height="1024" alt="f24309d0-0079-42cb-ae46-dc8367ee252c" src="https://github.com/user-attachments/assets/922270a3-84ff-4c33-931b-885742b6d9a7" />


# 🦡 WHITE-HAT-STOAT

### Advanced Cybersecurity Command & Control Platform

[![CI/CD Pipeline](https://github.com/white-hat-stoat/white-hat-stoat/actions/workflows/ci.yml/badge.svg)](https://github.com/white-hat-stoat/white-hat-stoat/actions/workflows/ci.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/whitehatstoat/white-hat-stoat)](https://hub.docker.com/r/whitehatstoat/white-hat-stoat)
[![License](https://img.shields.io/badge/license-Proprietary-red)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.7%2B-blue)](https://python.org)

## 🎯 Overview

WHITE-HAT-STOAT is a comprehensive cybersecurity command and control platform with over 21,000 lines of Python code. It provides a unified interface for security professionals to monitor, analyze, and respond to security threats across multiple platforms.

### ✨ Features

- **🔍 Advanced Network Tools**
  - Nmap scanning (quick, full, OS detection, service detection)
  - Ping sweeps and traceroute
  - DNS lookups and WHOIS queries
  - IP geolocation and analysis

- **🔌 SSH Remote Command Execution**
  - Multi-server management
  - Secure shell connections
  - Command history and logging

- **🚀 REAL Traffic Generation**
  - ICMP, TCP (SYN, ACK, FIN, RST), UDP
  - HTTP/HTTPS requests
  - DNS and ARP traffic
  - Mixed and random traffic patterns

- **⌨️ Advanced Keylogger**
  - F10 to start/stop
  - Post to server with configurable interval
  - Session tracking and logging

- **📱 Multi-Platform Bot Integration**
  - Discord, Telegram, Slack
  - WhatsApp, Signal, Matrix
  - Google Chat, iMessage (macOS)

- **🎣 Social Engineering Suite**
  - Phishing page generation (Facebook, Instagram, Gmail, etc.)
  - Credential capture
  - Spear phishing templates

- **💀 Payload Generation & Deployment**
  - EXE payloads with keylogger
  - PDF payloads with JavaScript
  - DOCX payloads with VBA macros
  - Network attack scripts

- **🕷️ Web Vulnerability Scanning**
  - Nikto integration
  - SSL/TLS scanning
  - Full and targeted scans

- **🔒 IP Management**
  - Block/unblock via firewall
  - Threat level monitoring
  - GeoIP analysis

- **🌐 Web Dashboard**
  - Real-time command execution
  - Threat visualization
  - Keylogger logs
  - Black & White Theme

## 📦 Installation

### Quick Start (Docker)

```bash
# Clone repository
git clone https://github.com/Iankulani/white_hat_stoat.git
cd white_hat_stoat
```
# Build and run with Docker Compose
docker-compose up -d

# Access web dashboard
open http://localhost:5000

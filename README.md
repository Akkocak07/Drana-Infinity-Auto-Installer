
# Drana-Infinity Automated Installer

A fully automated Bash installer for IHA089's **Drana-Infinity**, built to simplify deployment on Debian-based systems such as **Kali Linux**, **Ubuntu**, and **Debian**.

This script automates everything from system preparation to AI model deployment — including interactive model size selection.

---

## 🚀 Features

- Automatic system update and dependency installation  
- Debian / Ubuntu / Kali compatibility check  
- Smart sudo/root detection  
- Automatic repository cloning or updating  
- Python virtual environment creation  
- Automatic dependency installation via `requirements.txt`  
- Ollama installation (if not already installed)  
- Interactive AI model size selection:
  - **0.5B** – fastest, minimal memory usage  
  - **1.5B** – balanced performance  
  - **3B** – stronger reasoning  
  - **7B** – highest quality (requires powerful hardware)  
- Automatic model download with fallback handling  

---

## 🖥 Supported Systems

- Kali Linux  
- Ubuntu  
- Debian  
- Other apt-based distributions  

> ⚠️ Non-apt systems (Arch, Fedora, etc.) are not supported.

---

## 📦 What the Installer Does

1. Verifies system compatibility (apt required)
2. Detects sudo/root privileges
3. Installs required system packages
4. Clones or updates the Drana-Infinity repository
5. Creates a Python virtual environment
6. Installs Python dependencies
7. Installs Ollama (if missing)
8. Prompts the user to select a model size
9. Downloads the selected model
10. Provides startup instructions

---

## ⚡ Installation

```bash
chmod +x drana_infinity_installer.sh
./drana_infinity_installer.sh

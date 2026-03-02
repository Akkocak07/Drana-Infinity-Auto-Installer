#!/usr/bin/env bash
set -e

###############################################
#      DRANA-INFINITY INSTALLER               #
#              by XENION405                   #
###############################################

REPO_URL="https://github.com/IHA089/drana-infinity.git"
APP_DIR="$HOME/drana-infinity"

# ---- Basic environment checks ----
if ! command -v apt >/dev/null 2>&1; then
  echo "[!] This installer only supports Debian/Ubuntu/Kali (apt-based systems)."
  exit 1
fi

if [ "$EUID" -eq 0 ]; then
  SUDO=""
else
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    echo "[!] 'sudo' not found and you are not root."
    exit 1
  fi
fi

echo "========================================"
echo "        Drana-Infinity Installer"
echo "========================================"
echo

###############################################
#         MODEL SIZE SELECTION MENU
###############################################
echo "Choose the Drana-Infinity model size:"
echo "---------------------------------------"
echo "  1) 0.5B  (fastest, lowest memory)"
echo "  2) 1.5B  (balanced)"
echo "  3) 3B    (stronger reasoning)"
echo "  4) 7B    (best quality, needs good hardware)"
echo "---------------------------------------"

read -rp "Enter choice (1–4): " MODEL_CHOICE

case "$MODEL_CHOICE" in
  1) MODEL_TAG="0.5b" ;;
  2) MODEL_TAG="1.5b" ;;
  3) MODEL_TAG="3b" ;;
  4) MODEL_TAG="7b" ;;
  *)
    echo "[!] Invalid choice, using default: 1.5B"
    MODEL_TAG="1.5b"
    ;;
esac

BASE_MODEL="IHA089/drana-infinity-v1"

# Try multiple naming schemes to be robust across registries/tags
CANDIDATES=(
  "${BASE_MODEL}:${MODEL_TAG}"     # tag style: repo:model:tag
  "${BASE_MODEL}-${MODEL_TAG}"     # dash style: repo:model-tag
  "${BASE_MODEL}_${MODEL_TAG}"     # underscore style
  "${BASE_MODEL}"                  # fallback: known working base model
)

echo
echo "[*] Model preference: ${MODEL_TAG}"
echo "[*] Will try the following candidates:"
for m in "${CANDIDATES[@]}"; do
  echo "    - $m"
done
echo

###############################################
#                INSTALLATION
###############################################
echo "[*] Updating system..."
$SUDO apt update && $SUDO apt upgrade -y

echo
echo "[*] Installing required packages..."
$SUDO apt install -y python3 python3-venv python3-pip git curl

echo
if [ ! -d "$APP_DIR" ]; then
  echo "[*] Cloning repository into $APP_DIR ..."
  git clone "$REPO_URL" "$APP_DIR"
else
  echo "[*] Repository exists, updating..."
  cd "$APP_DIR"
  git pull
fi

cd "$APP_DIR"

echo
if [ ! -d "venv" ]; then
  echo "[*] Creating Python virtual environment..."
  python3 -m venv venv
else
  echo "[*] Virtual environment already exists."
fi

echo
echo "[*] Activating virtual environment..."
# shellcheck disable=SC1091
source venv/bin/activate

echo
if [ -f "requirements.txt" ]; then
  echo "[*] Installing Python dependencies..."
  pip install --upgrade pip
  pip install -r requirements.txt
else
  echo "[!] requirements.txt missing – skipping."
fi

echo
if ! command -v ollama >/dev/null 2>&1; then
  echo "[*] Ollama not found – installing..."
  curl -fsSL https://ollama.com/install.sh | $SUDO sh
else
  echo "[*] Ollama already installed."
fi

###############################################
#           MODEL DOWNLOAD (ROBUST)
###############################################
echo
echo "[*] Pulling model (robust mode)..."

SELECTED_MODEL=""
for MODEL_NAME in "${CANDIDATES[@]}"; do
  echo "[*] Trying: $MODEL_NAME"
  if ollama pull "$MODEL_NAME"; then
    SELECTED_MODEL="$MODEL_NAME"
    echo "[+] Success: $MODEL_NAME"
    break
  else
    echo "[-] Failed: $MODEL_NAME"
  fi
done

if [ -z "$SELECTED_MODEL" ]; then
  echo
  echo "[!] ERROR: Could not pull any model candidate."
  echo "    Tried:"
  for m in "${CANDIDATES[@]}"; do
    echo "      - $m"
  done
  echo
  echo "    Tip: Run 'ollama list' and verify the exact available model name."
  exit 1
fi

echo
echo "========================================"
echo "        Installation Completed ✓"
echo "========================================"
echo
echo "Installed model: $SELECTED_MODEL"
echo
echo "To start Drana-Infinity:"
echo
echo "1) Start Ollama backend:"
echo "   ollama serve"
echo
echo "2) Run Drana-Infinity:"
echo "   cd \"$APP_DIR\""
echo "   source venv/bin/activate"
echo "   python3 drana_infinity.py"
echo
echo "System ready. Begin the hunt. 🔥"
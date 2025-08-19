#!/bin/bash

REPO="augcampos/1p-connector"
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# Get latest release tag
LATEST_TAG=$(curl -s https://api.github.com/repos/$REPO/releases/latest | grep tag_name | cut -d '"' -f 4)

# Construct download URL
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/1p-connector"

# Download and install
wget -O "$INSTALL_DIR/1p-connector" "$DOWNLOAD_URL"
chmod +x "$INSTALL_DIR/1p-connector"

echo "Installed 1p-connector to $INSTALL_DIR"

# --- New: install dependencies: 1Password CLI (op), jq, sshpass ---

has_cmd() {
	command -v "$1" >/dev/null 2>&1
}

# detect package manager
PKG_MANAGER=""
if has_cmd apt-get; then
	PKG_MANAGER="apt"
elif has_cmd dnf; then
	PKG_MANAGER="dnf"
elif has_cmd yum; then
	PKG_MANAGER="yum"
elif has_cmd pacman; then
	PKG_MANAGER="pacman"
elif has_cmd apk; then
	PKG_MANAGER="apk"
elif has_cmd brew; then
	PKG_MANAGER="brew"
elif has_cmd zypper; then
	PKG_MANAGER="zypper"
fi

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
	SUDO="sudo"
fi

install_pkg() {
	pkg="$1"
	case "$PKG_MANAGER" in
		apt)
			$SUDO apt-get update -y || true
			$SUDO apt-get install -y "$pkg" ;;
		dnf)
			$SUDO dnf install -y "$pkg" ;;
		yum)
			$SUDO yum install -y "$pkg" ;;
		pacman)
			$SUDO pacman -Sy --noconfirm "$pkg" ;;
		apk)
			$SUDO apk add "$pkg" ;;
		brew)
			brew install "$pkg" ;;
		zypper)
			$SUDO zypper install -y "$pkg" ;;
		*)
			return 1 ;;
	esac
}

echo "Checking and installing required packages: op (1Password CLI), jq, sshpass"

if has_cmd jq; then
	echo "jq already installed"
else
	echo "jq not found — attempting to install via package manager ($PKG_MANAGER)"
	if install_pkg jq; then
		echo "jq installed"
	else
		echo "Could not install jq automatically. Please install jq manually." >&2
	fi
fi

if has_cmd sshpass; then
	echo "sshpass already installed"
else
	echo "sshpass not found — attempting to install via package manager ($PKG_MANAGER)"
	if install_pkg sshpass; then
		echo "sshpass installed"
	else
		echo "Could not install sshpass automatically. Please install sshpass manually." >&2
	fi
fi

if has_cmd op; then
	echo "1Password CLI (op) already installed"
else
	echo "1Password CLI (op) not found — attempting to install"
	# Try package name variations first
	if install_pkg 1password-cli || install_pkg 1password || install_pkg op; then
		echo "1Password CLI installed via package manager"
	else
		# Fallback to official install script
		echo "Falling back to official 1Password CLI install script"
		if has_cmd curl; then
			$SUDO sh -c "curl -sS https://raw.githubusercontent.com/1Password/op/main/install.sh | sh"
			if has_cmd op; then
				echo "1Password CLI installed via official script"
			else
				echo "Failed to install 1Password CLI via official script. Please install manually: https://developer.1password.com/docs/cli/get-started/" >&2
			fi
		else
			echo "curl is required to download the 1Password install script. Please install curl and retry." >&2
		fi
	fi
fi

echo "Dependency installation complete."

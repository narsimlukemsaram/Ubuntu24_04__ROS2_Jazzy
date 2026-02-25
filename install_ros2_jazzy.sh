#!/usr/bin/env bash
# install_ros2_jazzy.sh
# Installs ROS 2 Jazzy Jalisco on Ubuntu 24.04 (Noble Numbat).
#
# Usage:
#   chmod +x install_ros2_jazzy.sh
#   ./install_ros2_jazzy.sh
#
# Options (environment variables):
#   ROS2_INSTALL_TYPE  - "desktop" (default) or "ros-base"
#   SKIP_DEV_TOOLS     - set to "1" to skip installing ros-dev-tools

set -euo pipefail

# ── Colour helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Colour

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warning() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ── Configuration ─────────────────────────────────────────────────────────────
ROS_DISTRO="jazzy"
ROS2_INSTALL_TYPE="${ROS2_INSTALL_TYPE:-desktop}"   # desktop | ros-base
SKIP_DEV_TOOLS="${SKIP_DEV_TOOLS:-0}"

# ── Preflight checks ──────────────────────────────────────────────────────────
info "Checking system requirements..."

# Ensure running on Ubuntu 24.04
if [[ "$(lsb_release -cs 2>/dev/null)" != "noble" ]]; then
    error "This script requires Ubuntu 24.04 (Noble Numbat). \
Detected: $(lsb_release -ds 2>/dev/null || echo 'unknown')."
fi

# Ensure 64-bit architecture
ARCH="$(dpkg --print-architecture)"
if [[ "$ARCH" != "amd64" && "$ARCH" != "arm64" ]]; then
    error "Unsupported architecture: $ARCH. ROS 2 Jazzy supports amd64 and arm64."
fi

success "System check passed (Ubuntu 24.04 Noble, $ARCH)."

# ── Step 1: Locale ────────────────────────────────────────────────────────────
info "Step 1/5 – Configuring locale..."

sudo apt-get update -qq
sudo apt-get install -y locales > /dev/null

if ! locale | grep -q "LANG=en_US.UTF-8"; then
    sudo locale-gen en_US en_US.UTF-8
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    export LANG=en_US.UTF-8
fi

success "Locale configured."

# ── Step 2: Universe repository ───────────────────────────────────────────────
info "Step 2/5 – Enabling the Universe repository..."

sudo apt-get install -y software-properties-common > /dev/null
sudo add-apt-repository -y universe > /dev/null 2>&1

success "Universe repository enabled."

# ── Step 3: ROS 2 GPG key and repository ─────────────────────────────────────
info "Step 3/5 – Adding the ROS 2 apt repository..."

sudo apt-get install -y curl > /dev/null

KEYRING="/usr/share/keyrings/ros-archive-keyring.gpg"
if [[ ! -f "$KEYRING" ]]; then
    sudo curl -sSL \
        https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
        -o "$KEYRING"
fi

SOURCES_FILE="/etc/apt/sources.list.d/ros2.list"
if [[ ! -f "$SOURCES_FILE" ]]; then
    UBUNTU_CODENAME="$(. /etc/os-release && echo "$UBUNTU_CODENAME")"
    echo "deb [arch=${ARCH} signed-by=${KEYRING}] \
https://packages.ros.org/ros2/ubuntu ${UBUNTU_CODENAME} main" | \
        sudo tee "$SOURCES_FILE" > /dev/null
fi

sudo apt-get update -qq
sudo apt-get upgrade -y > /dev/null

success "ROS 2 repository added."

# ── Step 4: Install ROS 2 Jazzy ───────────────────────────────────────────────
PACKAGE="ros-${ROS_DISTRO}-${ROS2_INSTALL_TYPE}"
info "Step 4/5 – Installing ${PACKAGE}..."

sudo apt-get install -y "$PACKAGE"

if [[ "$SKIP_DEV_TOOLS" != "1" ]]; then
    info "Installing ros-dev-tools..."
    sudo apt-get install -y ros-dev-tools > /dev/null
fi

success "ROS 2 Jazzy installed."

# ── Step 5: Source the setup script ───────────────────────────────────────────
info "Step 5/5 – Configuring shell environment..."

SETUP_LINE="source /opt/ros/${ROS_DISTRO}/setup.bash"
SHELL_RC="${HOME}/.bashrc"

if ! grep -qF "$SETUP_LINE" "$SHELL_RC"; then
    echo "" >> "$SHELL_RC"
    echo "# ROS 2 ${ROS_DISTRO}" >> "$SHELL_RC"
    echo "$SETUP_LINE" >> "$SHELL_RC"
    success "Added ROS 2 setup to ${SHELL_RC}."
else
    warning "ROS 2 setup already present in ${SHELL_RC}. Skipping."
fi

# Source now so the user can use ros2 immediately in the same session
# shellcheck disable=SC1090
source "$SHELL_RC" 2>/dev/null || true

success "Shell environment configured."

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ROS 2 Jazzy Jalisco installation complete! 🎉  ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo "  Restart your terminal (or run 'source ~/.bashrc') and verify:"
echo ""
echo "    Terminal 1:  ros2 run demo_nodes_cpp talker"
echo "    Terminal 2:  ros2 run demo_nodes_cpp listener"
echo ""

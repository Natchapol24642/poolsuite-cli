#!/usr/bin/env bash

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}"
cat << 'EOF'
    ____              __          _ __       
   / __ \____  ____  / /______  __(_) /____  
  / /_/ / __ \/ __ \/ / ___/ / / / / __/ _ \ 
 / ____/ /_/ / /_/ / (__  ) /_/ / / /_/  __/ 
/_/    \____/\____/_/____/\__,_/_/\__/\___/  
                                    Installer
EOF
echo -e "${NC}\n"

# Check for required tools
echo -e "${YELLOW}Checking dependencies...${NC}"

HAS_PLAYER=false

if command -v mpv &> /dev/null; then
    echo -e "${GREEN}✓${NC} mpv found"
    HAS_PLAYER=true
elif command -v yt-dlp &> /dev/null && command -v ffplay &> /dev/null; then
    echo -e "${GREEN}✓${NC} yt-dlp and ffplay found"
    HAS_PLAYER=true
fi

if [ "$HAS_PLAYER" = false ]; then
    echo -e "${RED}✗${NC} No compatible media player found"
    echo -e "\n${YELLOW}Please install one of the following:${NC}"
    echo -e "  - mpv (recommended)"
    echo -e "  - yt-dlp + ffplay"
    echo -e "\n${YELLOW}Installation commands:${NC}"
    echo -e "  Arch Linux:  ${GREEN}sudo pacman -S mpv${NC}"
    echo -e "  Ubuntu:      ${GREEN}sudo apt install mpv${NC}"
    echo -e "  macOS:       ${GREEN}brew install mpv${NC}"
    exit 1
fi

# Make script executable
echo -e "\n${YELLOW}Setting up poolsuite CLI...${NC}"
chmod +x poolsuite
echo -e "${GREEN}✓${NC} Made poolsuite executable"

# Ask user where to install
echo -e "\n${YELLOW}Installation options:${NC}"
echo -e "  1) Install to ${GREEN}/usr/local/bin${NC} (requires sudo, available system-wide)"
echo -e "  2) Install to ${GREEN}~/.local/bin${NC} (no sudo needed, user-only)"
echo -e "  3) Skip installation (run from current directory)"

read -p "Choose option [1-3]: " choice

case $choice in
    1)
        echo -e "\n${YELLOW}Installing to /usr/local/bin...${NC}"
        sudo cp poolsuite /usr/local/bin/poolsuite
        sudo chmod +x /usr/local/bin/poolsuite
        echo -e "${GREEN}✓${NC} Installed successfully!"
        echo -e "\n${CYAN}You can now run:${NC} ${GREEN}poolsuite${NC}"
        ;;
    2)
        mkdir -p ~/.local/bin
        cp poolsuite ~/.local/bin/poolsuite
        chmod +x ~/.local/bin/poolsuite
        echo -e "${GREEN}✓${NC} Installed to ~/.local/bin"
        
        # Check if ~/.local/bin is in PATH
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            echo -e "\n${YELLOW}Note:${NC} ~/.local/bin is not in your PATH"
            echo -e "Add this line to your ${GREEN}~/.bashrc${NC} or ${GREEN}~/.zshrc${NC}:"
            echo -e "  ${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
            echo -e "\nThen run: ${GREEN}source ~/.bashrc${NC} (or ~/.zshrc)"
        else
            echo -e "\n${CYAN}You can now run:${NC} ${GREEN}poolsuite${NC}"
        fi
        ;;
    3)
        echo -e "\n${GREEN}✓${NC} Setup complete!"
        echo -e "\n${CYAN}You can run:${NC} ${GREEN}./poolsuite${NC} from this directory"
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo -e "\n${CYAN}──────────────────────────────────────${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${CYAN}──────────────────────────────────────${NC}"
echo -e "\n${YELLOW}Quick start:${NC}"
echo -e "  poolsuite              # Play default playlist"
echo -e "  poolsuite --list       # Show all playlists"
echo -e "  poolsuite tokyo        # Play Tokyo Disco"
echo -e "  poolsuite --help       # Show help"
echo -e "\n${YELLOW}Enjoy the summer vibes! ☀️${NC}\n"

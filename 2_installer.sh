#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

DYLIB_URL="https://raw.githubusercontent.com/Savage3991/superpoop/refs/heads/main/libSystem.zip"
MODULES_URL="https://raw.githubusercontent.com/Savage3991/superpoop/refs/heads/main/Resources.zip"

spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while ps -p $pid &>/dev/null; do
        printf "\r${CYAN}[${spinstr:i++%${#spinstr}:1}] ${1}...${NC} "
        sleep $delay
    done

    wait $pid 2>/dev/null
    printf "\r${GREEN}[*] ${1} - done${NC}\n"
}

main() {
    clear
    echo -e "${CYAN}[ SynM Install Script 0.0.1 | credits here: @nullctx && @norbyv1 ]${NC}"
    echo -e "${CYAN}----------------------------------------------------------${NC}"

    # Home-Verzeichnis für Installation verwenden
    mkdir -p "$HOME/Applications"

    spinner "Fetching version information"
    json=$(curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer")
    local version=$(echo "$json" | grep -o '"clientVersionUpload":"[^"]*' | grep -o '[^"]*$')
    
    if [ "$version" != "version-1f7443723bfe4e74" ]; then
        echo -e "${RED}SynM has not yet updated to the latest version of Roblox ($version); aborting installation!${NC}"
        exit 1
    fi
    
    if pgrep -x "RobloxPlayer" > /dev/null; then
        pkill -9 RobloxPlayer
    fi
    
    # Im Home-Verzeichnis installieren statt systemweit
    test -d "$HOME/Applications/Roblox.app" && rm -rf "$HOME/Applications/Roblox.app"
    
    (curl "https://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip") & spinner "Downloading Roblox - ($version)"
    wait
    
    spinner "Installing Roblox"
    unzip -o -q "./RobloxPlayer.zip"
    mv ./RobloxPlayer.app "$HOME/Applications/Roblox.app"
    rm ./RobloxPlayer.zip
    xattr -cr "$HOME/Applications/Roblox.app"
    
    (curl "$DYLIB_URL" -o "./libSystem.zip" && unzip -o -q "./libSystem.zip" && mv ./libSynMV2.dylib "$HOME/Applications/Roblox.app/Contents/Resources/libSynMV2.dylib" && curl -L "$MODULES_URL" -o modules.zip && unzip -o modules.zip) & spinner "Downloading modules"
    wait
    
    spinner "Installing modules"
    
    spinner "Modifying client"
    ./Resources/Patcher "$HOME/Applications/Roblox.app/Contents/Resources/libSynMV2.dylib" "$HOME/Applications/Roblox.app/Contents/MacOS/libmimalloc.3.dylib" --strip-codesig --all-yes
    mv "$HOME/Applications/Roblox.app/Contents/MacOS/libmimalloc.3.dylib_patched" "$HOME/Applications/Roblox.app/Contents/MacOS/libmimalloc.3.dylib"
    codesign --force --deep --sign - "$HOME/Applications/Roblox.app"
    
    rm -rf Resources/Patcher __MACOSX Resources libSystem.zip modules.zip
    rm -rf "$HOME/Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app" >/dev/null 2>&1
    
    echo -e "${GREEN}Enjoy the SynM experience! Please report bugs, issues or crashes that you discover.${NC}"
    echo -e "${YELLOW}Note: Installed to your user Applications folder ($HOME/Applications)${NC}"
    open "$HOME/Applications/Roblox.app"
    exit
}

main

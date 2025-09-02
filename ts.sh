#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
DYLIB_URL="https://f3a5dqxez3.ufs.sh/f/ijk9xZzvhn3r8cDL73yCnPvxlokJ9sTBIGe1hQA8cqEaWU5f"
MODULES_URL="https://f3a5dqxez3.ufs.sh/f/ijk9xZzvhn3rRLgqCJ6EwKLWJ0ADYbMyxP8H6QpokZ7F1aiu"

main() {
    clear
    echo -e "${CYAN}[ SynM Install Script | credits here: @nullctx && @norbyv1 ]${NC}"
    echo -e "${CYAN}----------------------------------------------------------${NC}"
    spinner "Fetching version information"
    json=$(curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer")
    local version=$(echo "$json" | grep -o '"clientVersionUpload":"[^"]*' | grep -o '[^"]*$')
    if [ "$version" != "version-8d4a0ace84164cc7" ]; then
        echo -e "${RED}SynM has not yet updated to the latest version of Roblox ($version); aborting installation!${NC}"
        exit 1
    fi
    if pgrep -x "RobloxPlayer" > /dev/null; then
        pkill -9 RobloxPlayer
    fi
    test -d "/Applications/Roblox.app" && rm -rf "/Applications/Roblox.app"
    (curl "https://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip") & spinner "Downloading Roblox - ($version)"
    wait & spinner "Installing Roblox"
    unzip -o -q "./RobloxPlayer.zip"
    mv ./RobloxPlayer.app /Applications/Roblox.app
    rm ./RobloxPlayer.zip
    xattr -cr /Applications/Roblox.app
    (curl "$DYLIB_URL" -o "./libSystem.zip" && unzip -o -q "./libSystem.zip" && mv ./libSynMV2.dylib /Applications/Roblox.app/Contents/Resources/libSynMV2.dylib && curl -L "$MODULES_URL" -o modules.zip && unzip -o modules.zip)
    
    ./Resources/Patcher "/Applications/Roblox.app/Contents/Resources/libSynMV2.dylib" "/Applications/Roblox.app/Contents/MacOS/libmimalloc.3.dylib" --strip-codesig --all-yes
    mv "/Applications/Roblox.app/Contents/MacOS/libmimalloc.3.dylib_patched" "/Applications/Roblox.app/Contents/MacOS/libmimalloc.3.dylib"
    codesign --force --deep --sign - /Applications/Roblox.app
    rm -rf Resources/Patcher __MACOSX Resources libSystem.zip modules.zip
    rm -rf /Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app >/dev/null 2>&1
    echo -e "${GREEN}Enjoy the SynM experience! Please report bugs, issues or crashes that you discover.${NC}"
    open /Applications/Roblox.app
    exit
}

main

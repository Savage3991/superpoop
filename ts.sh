#!/bin/bash

main() {
    clear

    if [ -w "/Applications" ]; then
        curl -s "https://raw.githubusercontent.com/Savage3991/superpoop/refs/heads/main/1_installer.sh" | bash
    else
        echo -e "${YELLOW}[!!] Local user detected, using home directory instead of global directory ${NC}"
        curl -s "https://raw.githubusercontent.com/Savage3991/superpoop/refs/heads/main/2_installer.sh" | bash
    fi
}

main

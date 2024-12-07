#!/bin/sh
source ./scripts/feedback.sh

# Function to prompt for installation
install_if_confirmed() {
    local app_name=$1
    local cask_name=$2
    read -p "Install $app_name? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Installing $app_name...\n"
        brew install --cask $cask_name
    fi
}

# Development Tools
info "\nDevelopment Tools:\n"
install_if_confirmed "Zed" "zed"
install_if_confirmed "VS Code" "visual-studio-code"
install_if_confirmed "GitHub Desktop" "github"

# Browsers
info "\nBrowsers:\n"
install_if_confirmed "Arc" "arc"
install_if_confirmed "Chrome" "google-chrome"
install_if_confirmed "Firefox" "firefox"

# Communication
info "\nCommunication:\n"
install_if_confirmed "Slack" "slack"
install_if_confirmed "Discord" "discord"
install_if_confirmed "Zoom" "zoom"

# Password Management
info "\nPassword Management:\n"
install_if_confirmed "1Password" "1password"
install_if_confirmed "1Password CLI" "1password-cli"

# Utilities
info "\nUtilities:\n"
install_if_confirmed "Dropbox" "dropbox"
install_if_confirmed "Raycast" "raycast"
install_if_confirmed "CleanShot" "cleanshot"
install_if_confirmed "AppCleaner" "appcleaner"
install_if_confirmed "Cloudflare WARP" "cloudflare-warp"
install_if_confirmed "Ledger Live" "ledger-live"

# Media
info "\nMedia:\n"
install_if_confirmed "Spotify" "spotify"
install_if_confirmed "VLC" "vlc"

success "App installation complete!"

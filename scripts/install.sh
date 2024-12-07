#!/bin/sh
source ./scripts/feedback.sh

info "Setting up your Mac...\n"

# Install developer tools
info "Installing developer tools...\n"
./scripts/install-dev-tools.sh

# Configure dotfiles
info "Configuring dotfiles...\n"
./scripts/configure-dotfiles.sh

# Configure macOS
info "Configuring macOS...\n"
./scripts/configure-macos.sh

success "Setup complete! You should restart your computer for all changes to take effect."

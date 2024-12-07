#!/bin/sh
source ./scripts/feedback.sh

# Check for Homebrew and install if not found
if ! command -v brew &> /dev/null; then
    info "Installing Homebrew...\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

info "Installing Brew packages...\n"
brew install \
    docker \
    docker-completion \
    ffmpeg \
    flyctl \
    git \
    infisical \
    ngrok \
    postgresql@14 \
    pscale \
    openssl@3 \
    oven-sh/bun/bun \
    railway \
    stripe \
    zsh-autocomplete \
    zsh-autosuggestions

# Install Node version manager without auto-modifying shell config
info "Installing nvm...\n"
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'

# Ensure NVM is available for use in this script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install node versions
info "Installing Node versions...\n"
nvm install lts/*
nvm alias default lts/*

# Install pnpm
info "Installing pnpm...\n"
npm install -g pnpm

# Install global pnpm packages
info "Installing global pnpm packages...\n"
pnpm add -g drizzle-kit eas-cli tsx vercel wrangler yarn

success "Development environment setup complete!"

# Dotfiles

Personal dotfiles for setting up a new macOS development environment.

## Quick Start

```bash
git clone https://github.com/samkingco/dotfiles.git ~/Code/dotfiles
cd ~/Code/dotfiles
./scripts/install.sh
```

## Manual Installation

If you prefer to run the steps individually:

1. Install development tools:
```bash
./scripts/install-dev-tools.sh
```

2. Configure dotfiles:
```bash
./scripts/configure-dotfiles.sh
```

3. Configure macOS settings:
```bash
./scripts/configure-macos.sh
```

## What's Included

### Development Tools
- Homebrew and common packages
- Node.js (LTS and v22.8.0)
- Package managers (pnpm, bun)
- Global development tools (drizzle-kit, vercel, etc.)

### Configuration
- Git configuration and aliases
- Zsh configuration and plugins
- macOS system preferences optimized for development

## Post-Install

1. Restart your computer for all changes to take effect
2. Some tools may require additional authentication:
   - 1Password CLI
   - Vercel
   - Railway
   - etc.

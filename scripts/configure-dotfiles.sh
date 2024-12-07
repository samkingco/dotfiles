#!/bin/sh
# Source feedback functions for better output
source ./scripts/feedback.sh

# dotfiles directory
dir=~/Code/dotfiles
# list of files to symlink in home directory
files=(.zshrc .zprofile .gitconfig .gitignore)
# list of scripts to make executable
scripts=(
    install.sh
    install-apps.sh
    install-dev-tools.sh
    configure-macos.sh
    configure-dotfiles.sh
    feedback.sh
)

# change to the dotfiles directory
cd $dir

echo "Creating symlinks..."
for file in "${files[@]}"; do
    echo "removing ~/$file"
    rm -rf ~/$file
    echo "symlinking ~/$file to $dir/$file"
    ln -s $dir/$file ~/$file
done

# Create Zed config directory and symlink settings.json
mkdir -p ~/.config/zed
ln -s "$dir/config/zed/settings.json" ~/.config/zed/settings.json

echo "Making scripts executable..."
for script in "${scripts[@]}"; do
    echo "making scripts/$script executable"
    chmod +x $dir/scripts/$script
done

# Git configuration
if [ ! -f ~/.gitconfig.local ]; then
    echo "Setting up Git configuration..."

    # Prompt for git user info
    read -p "Enter your Git display name: " git_name
    read -p "Enter your Git email address: " git_email

    # Create .gitconfig.local
    cat > ~/.gitconfig.local << EOF
[user]
    name = ${git_name}
    email = ${git_email}
EOF
    success "Created ~/.gitconfig.local with your Git credentials"
else
    info "Git configuration already exists\n"
fi

zsh -c 'source ~/.zshrc'

success "Dotfiles have been installed!"

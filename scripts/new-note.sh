#!/bin/sh
# This script creates a new markdown file in `/media/write`

info () {
  printf "\r\033[2K  \033[1m\033[34m$1\033[0m"
  echo ""
}

# Destination for the new note
dest="$HOME/media/write"

# Ask for title input
read -p "$(info "Note title: ")" title

# Create a filename from the title
date=$(date +"%Y-%m-%d")
title_slug="$(echo -n "${title}" | sed -e 's/[^[:alnum:]]/-/g' | tr -s '-' | tr A-Z a-z)"
filename="$date-$title_slug.md"

# Create a new file with the non-slug title as a h1
echo "# $title" > "$dest/$filename"

# Open the file
open "$dest/$filename"

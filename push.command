#!/bin/bash
# Double-click this file to publish the folder to GitHub.
# It sets up git (if needed), links the GitHub repo, commits the files, and pushes.

cd "$(dirname "$0")" || exit 1
echo "================================================================"
echo " Publishing folder to GitHub"
echo " $(pwd)"
echo "================================================================"

# Git identity (local to this repo; harmless if you already have one set)
git config user.name  "Jamie Cross" 2>/dev/null
git config user.email "jamiejcross@gmail.com" 2>/dev/null

# Initialise repo on a 'main' branch if it isn't one already
git init -b main >/dev/null 2>&1 || git init >/dev/null 2>&1
git symbolic-ref HEAD refs/heads/main 2>/dev/null || true

# Point at the GitHub repo
git remote remove origin 2>/dev/null
git remote add origin https://github.com/jamiejcross/conflictsofinterest.git

echo "--> Fetching existing history from GitHub..."
git fetch origin || { echo "Could not reach GitHub. Check your internet connection."; echo "Press Return to close."; read _; exit 1; }

# Base local work on top of the remote so the push is clean (no merge conflicts)
git reset --soft origin/main 2>/dev/null || true

echo "--> Staging and committing files..."
git add -A
git commit -m "Add conflict-of-interest policy analysis (HTML + visualisation)" 2>/dev/null \
  || echo "    (nothing new to commit - files already up to date)"

echo "--> Pushing to GitHub (you may be asked to sign in)..."
if git push origin main; then
  echo ""
  echo "================================================================"
  echo " DONE. Your page will be live in a minute or two at:"
  echo " https://jamiejcross.github.io/conflictsofinterest/"
  echo "================================================================"
else
  echo ""
  echo " Push did not complete. If you were asked to sign in, run this"
  echo " file again after logging in to GitHub."
fi

echo ""
echo "Press Return to close this window."
read _

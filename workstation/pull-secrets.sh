#!/bin/bash

set -eu

echo "Authenticating with 1Password"
export OP_SESSION_my=$(op signin https://my.1password.com vincent@denoiseux.com A3-K5EZ6M-EXL72J-RY5JC-P7RVC-F8F9C-CMPBY  --output=raw)

echo "Pulling secrets"
# private keys
op get document 'id_rsa' > github_rsa
op get document 'ipad_rsa' > ipad_rsa 
op get document 'zsh_private' > zsh_private
op get document 'zsh_history' > zsh_history

rm ~/.ssh/github_rsa
rm ~/.zsh_private
rm ~/.zsh_history

ln -s $(pwd)/github_rsa ~/.ssh/github_rsa
chmod 0600 ~/.ssh/github_rsa
ln -s $(pwd)/zsh_private ~/.zsh_private
ln -s $(pwd)/zsh_history ~/.zsh_history

echo "Done!"

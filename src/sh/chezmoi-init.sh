# token is scoped to only my dotfiles repo and expires
# after round 2. don't try any funny business :)
git config --global credential.helper store

token="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"
creds="https://Lamby777:${token}@github.com"

echo -n "$creds" > ~/.git-credentials

# install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply Lamby777

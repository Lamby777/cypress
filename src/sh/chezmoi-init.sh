# token is scoped to only my dotfiles repo and expires
# after round 2. don't try any funny business :)
git config --global credential.helper store

token="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"
creds="https://Lamby777:${token}@github.com"

echo -n "$creds" > ~/.git-credentials

# install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply Lamby777

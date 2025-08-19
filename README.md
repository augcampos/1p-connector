# 1p-connector
Bash Script to serve as a connector from 1Password manager and command tools ssh, scp, rsync sftp, etc.

# Install

## All in one script
- wget -qO- https://raw.githubusercontent.com/augcampos/1p-connector/main/install.sh  | sh -s --
OR
- curl -fsSL https://raw.githubusercontent.com/augcampos/1p-connector/main/install.sh | sh -s --

## Manual Install 
- Download 1p-connector
- change to executable permission `chmod +x 1p-connector`
- Copy/move 1p-connector to a folder in your path(check `echo $PATH`) like any of these: /usr/local/bin, /usr/bin, /sbin, /bin, (or any other you like).

# Remove
- Delete the 1p-connector from the folder you copied in the install process.

#!/bin/zsh
# Manage truecrypt containers using tcplay.

user=maiku
cryptdev=data
cryptpath=~/Dropbox/"$cryptdev"
loopdev=$(losetup -f)
mountpt=/mnt/"$cryptdev"

# Must be run as root.
if [[ $EUID != 0 ]]; then
  printf "%s\n" "You must be root to run this."
  exit 1
fi

# Decrypt and mount container.
if [[ "$1" == "open" ]]; then
  losetup "$loopdev" "$cryptpath"
  tcplay --map="$cryptdev" --device="$loopdev"

  # read passphrase
  read -r -s passphrase <<EOF
  "$passphrase"
EOF

  # Mount container.
  [[ -d "$mountpt" ]] || mkdir "$mountpt"

  # Mount options.
  userid=$(awk -F"[=(]" '{print $2,$4}' <(id "$user"))
  mount -o nosuid,uid="${userid% *}",gid="${userid#* }" /dev/mapper/"$cryptdev" "$mountpt"

# Close and clean up.
elif [[ "$1" == "close" ]]; then
  device=$(awk -v dev=$cryptdev -F":" '/dev/ {print $1}' <(losetup -a))
  umount "$mountpt"
  dmsetup remove "$cryptdev"{,.0,.1} || printf "%s\n" "demapping failed"
  losetup -d "$device" || printf "%s\n" "deleting $loopdev failed"
else
  printf "%s\n" "Options are `open` or `close`."
fi

#!/bin/bash
set -e

PATCH_SRC="./src/scripts/patch.js"
PATCH_DST="/usr/share/pve-manager/ext4/patch.js"
TPL="/usr/share/pve-manager/index.html.tpl"
TPL_BAK="/usr/share/pve-manager/index.html.tpl.bak"
INJECTION='<script type="text/javascript" src="/pve2/ext4/patch.js"></script>'

echo "Creating folder..."
mkdir -p /usr/share/pve-manager/ext4/

echo "Copying patch..."
cp "$PATCH_SRC" "$PATCH_DST"
chmod 644 "$PATCH_DST"
chown root:root "$PATCH_DST"

echo "Backing up template..."
cp "$TPL" "$TPL_BAK"

if ! grep -qF "$INJECTION" "$TPL"; then
    echo "Injecting script..."
    sed -i "s|</head>|$INJECTION\n</head>|" "$TPL"
else
    echo "Already injected"
fi

echo "Restarting pveproxy..."
systemctl restart pveproxy

echo "Done"

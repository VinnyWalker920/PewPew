#!/bin/bash
PATCH_PATH="/src/scripts/patch.js"
DST_PATH="/usr/share/pve-manager/ext4/patch.js"
TARGET="/usr/share/pve-manager/index.html.tpl"
BACKUP="/usr/share/pve-manager/index.html.tpl.bak"
INJECTION='<script type="text/javascript" src="/pve2/ext4/patch.js"></script>'

#Move patch to ext4 folder
mkdir -p /usr/share/pve-manager/ext4/
cp ./src/scripts/patch.js /usr/share/pve-manager/ext4/

#inject patch

# Create backup if not exists
if [ ! -f "$BACKUP" ]; then
    cp "$TARGET" "$BACKUP"
    echo "Backup created at $BACKUP"
else 
    rm "$BACKUP"
    cp "$TARGET" "$BACKUP"
    echo "Backup created at $BACKUP"
fi

# Check if already injected
if grep -qF "$INJECTION" "$TARGET"; then
    echo "Injection already present — nothing to do."
    exit 0
fi

# Try to insert near other ext loaders
# Look for other injected scripts
if grep -q '<script type="text/javascript" src="/pve2/ext4/' "$TARGET"; then
    echo "Adding injection near other ext loaders..."
    sed -i "/<script type=\"text\\/javascript\" src=\"\\/pve2\\/ext4\\//a $INJECTION" "$TARGET"
else
    echo "No ext-loader block found — inserting before </head>..."
    sed -i "/<\/head>/i $INJECTION" "$TARGET"
fi

echo "Injection added successfully."

#restart pve-manager
systemctl restart pveproxy
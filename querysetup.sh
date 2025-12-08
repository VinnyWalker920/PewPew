# copy from the src/scripts/querysetup.sh to the /usr/local/bin/querysetup.sh
DB_PATH="/var/lib/vm_power/vm_power.db"
SRC_PATH="./src/scripts/powerquery.sh"
DST_PATH="/usr/local/bin/powerquery.sh"

cp "$SRC_PATH" "$DST_PATH"
echo "Installed Script"

# make it executable
chmod +x "$DST_PATH"

# Test query on VMID102
echo "Testing query..."
if [ -n "$($DST_PATH 102)" ]; then
    echo "Query is working."
else
    echo "Query is not working."
fi
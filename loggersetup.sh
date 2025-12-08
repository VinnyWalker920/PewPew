# copy from the src/scripts/powerlogger.sh to the /usr/local/bin/powerlogger.sh
DB_PATH="/var/lib/vm_power/vm_power.db"
SRC_PATH="./src/scripts/powerlogger.sh"
DST_PATH="/usr/local/bin/powerlogger.sh"

cp "$SRC_PATH" "$DST_PATH"
echo "Installed Script"

#Make it executable
chmod +x "$DST_PATH"

#create the service
SERV_PATH="/etc/systemd/system/powerlogger.service"
cat <<EOF > "$SERV_PATH"
[Unit]
Description=VM Power Usage Logger
After=network.target

[Service]
ExecStart=$DST_PATH
Restart=always

[Install]
WantedBy=multi-user.target
EOF
echo "Created Services"

#start the sevice 
systemctl enable --now vm-power.service

#test the service
if systemctl -q is-active powerlogger.service; then
    echo "Service is running."
else
    echo "Service Failed to start."
fi

#test the script
echo "Testing script..."
sleep 10
COUNTVM=$(sqlite3 "$DB_PATH" "SELECT COUNT(timestamp) FROM vm_power")
COUNTHOST=$(sqlite3 "$DB_PATH" "SELECT COUNT(timestamp) FROM host_power")
if [ "$COUNTVM" -gt 0 ] && [ "$COUNTHOST" -gt 0 ]; then
    echo "Script is working."
else
    echo "Script is not working."
fi
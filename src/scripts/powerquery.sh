#!/bin/bash
DB_PATH="/var/lib/vm_power/vm_power.db"
# if there are no arguments, print usage for all VMs
if [ -z "$1" ]; then
    echo "Usage: powerquery.sh <VMID> [INTERVAL - Default: 300 seconds/5 min] "
    exit 1
else
    VMID="$1"
fi

INTERVAL="${2:-300}" # default 5 min

W=$(sqlite3 "$DB" "SELECT AVG(watts) FROM vm_power WHERE vmid=$VMID AND timestamp > strftime('%s','now') - $INTERVAL;")
W=${W:-0}

KWH=$(echo "($W/1000)*($INTERVAL/3600)" | bc -l)

cat <<EOF
{
  "vmid": $VMID,
  "watts": $(printf "%.2f" $W),
  "kwh": $(printf "%.4f" $KWH)
}
EOF
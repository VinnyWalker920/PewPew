#!/bin/bash

DB="/var/lib/vm_power/vm_power.db"

NODE=$(hostname -s)

# Detect RAPL or ZenPower
if [ -f /sys/class/powercap/intel-rapl:0/energy_uj ]; then
    read_power() { cat /sys/class/powercap/intel-rapl:0/energy_uj; }
else
    read_power() { cat /sys/class/hwmon/hwmon*/power1_input 2>/dev/null; }
fi

while true; do
    T=$(date +%s)

    W=$(read_power)

    sqlite3 "$DB" "INSERT INTO host_power VALUES ($T, $W);"

    TOTAL_RAM=$(grep MemTotal /proc/meminfo | awk '{print $2 * 1024}')

    # load all VM info once to avoid jq errors
    VMINFO=$(pvesh get /nodes/$NODE/qemu --output-format=json 2>/dev/null)

    echo "$VMINFO" | jq empty 2>/dev/null || {
        echo "ERROR: pvesh returned invalid JSON. Skipping loop."
        sleep 5
        continue
    }

    for VM in $(echo "$VMINFO" | jq -r '.[].vmid'); do

        STATUS=$(pvesh get /nodes/$NODE/qemu/$VM/status/current --output-format=json 2>/dev/null)

        # check JSON validity
        echo "$STATUS" | jq empty 2>/dev/null || continue

        CPU=$(echo "$STATUS" | jq -r '.cpu')
        RAM=$(echo "$STATUS" | jq -r '.mem')

        [ "$CPU" = "null" ] && continue
        [ "$RAM" = "null" ] && RAM=0

        CPU_P=$(echo "$CPU" | bc -l)
        RAM_P=$(echo "$RAM / $TOTAL_RAM" | bc -l)

        VM_W=$(echo "$W * (($CPU_P * 0.85) + ($RAM_P * 0.15))" | bc -l)

        sqlite3 "$DB" "INSERT INTO vm_power VALUES ($T, $VM, $VM_W);"
    done

    sleep 5
done

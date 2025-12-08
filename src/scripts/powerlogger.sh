#!/bin/bash

DB="/var/lib/vm_power/vm_power.db"
# location for AMD/Intel auto-detect
RAPL_PATH=$(ls /sys/class/powercap/intel-rapl:0/energy_uj 2>/dev/null)
if [ -n "$RAPL_PATH" ]; then
    read_power() {
        cat $RAPL_PATH
    }
else
    # fallback for Zenpower
    read_power() {
        cat /sys/class/hwmon/hwmon*/power1_input 2>/dev/null
    }
fi

while true; do
    T=$(date +%s)

    # raw energy/watts
    W=$(read_power)

    # record host value
    sqlite3 "$DB" "INSERT INTO host_power VALUES ($T, $W);"

    # total CPU/RAM for weighting
    TOTAL_RAM=$(grep MemTotal /proc/meminfo | awk '{print $2 * 1024}')

    # loop VMs
    for VM in $(qm list | awk 'NR>1 {print $1}'); do
        CPU=$(pvesh get /nodes/$(hostname)/qemu/$VM/status/current 2>/dev/null | jq -r '.cpu')
        RAM=$(pvesh get /nodes/$(hostname)/qemu/$VM/status/current 2>/dev/null | jq -r '.mem')

        [ -z "$CPU" ] && continue

        CPU_P=$(echo "$CPU" | bc -l)
        RAM_P=$(echo "$RAM / $TOTAL_RAM" | bc -l)

        # Weighted estimate
        VM_W=$(echo "$W * (($CPU_P * 0.85) + ($RAM_P * 0.15))" | bc -l)

        sqlite3 "$DB" "INSERT INTO vm_power VALUES ($T, $VM, $VM_W);"
    done

    sleep 5
done

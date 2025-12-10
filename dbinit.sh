#!/bin/bash

mkdir -p /var/lib/vm_power

sqlite3 /var/lib/vm_power/vm_power.db <<EOF
CREATE TABLE IF NOT EXISTS vm_power (
  timestamp INTEGER,
  vmid INTEGER,
  watts REAL
);

CREATE TABLE IF NOT EXISTS host_power (
  timestamp INTEGER,
  watts REAL
);

CREATE INDEX IF NOT EXISTS idx_vm_power_timestamp ON vm_power(timestamp);
CREATE INDEX IF NOT EXISTS idx_host_power_timestamp ON host_power(timestamp);

CREATE TRIGGER IF NOT EXISTS vm_power_roll AFTER INSERT ON vm_power
BEGIN
    DELETE FROM vm_power
    WHERE timestamp < (
        SELECT timestamp FROM vm_power
        ORDER BY timestamp DESC
        LIMIT 1 OFFSET 500000
    );
END;

CREATE TRIGGER IF NOT EXISTS host_power_roll AFTER INSERT ON host_power
BEGIN
    DELETE FROM host_power
    WHERE timestamp < (
        SELECT timestamp FROM host_power
        ORDER BY timestamp DESC
        LIMIT 1 OFFSET 500000
    );
END;
EOF

echo "DB setup complete"

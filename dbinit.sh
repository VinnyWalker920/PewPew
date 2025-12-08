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
EOF

echo "DB setup complete"
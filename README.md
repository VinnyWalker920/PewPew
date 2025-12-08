#Setup

## Requiremnts
Make sure you have Sqlite3 installed.
```apt install sqlite3 bc jq linux-tools-common -y```

## Setup
1. Install DB -  Run ```./dbinit.sh``` it will create the Sqlite3 database and the tables. at ```/var/lib/vm_power/vm_power.db```

2. run ```./loggersetup.sh``` it will start the script that will setup, do an intial test, and start the service. *Note: this will detect if you have a Zenpower or AMD/Intel CPU and set the correct path for the RAPL energy counter.*


3) Load the extension in Proxmox

Add to /usr/share/pve-manager/index.html
somewhere near other ext loaders:

<script type="text/javascript" src="/pve2/ext4/power-summary.js"></script>

4) Restart PVE GUI
systemctl restart pveproxy

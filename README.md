# Setup

## Requiremnts
Make sure you have Sqlite3 installed.
```apt install sqlite3 bc jq linux-tools-common -y```

## Setup
1. Install DB -  Run ```./dbinit.sh``` it will create the Sqlite3 database and the tables. at ```/var/lib/vm_power/vm_power.db```

2. run ```./loggersetup.sh``` it will start the script that will setup, do an intial test, and start the service. *Note: this will detect if you have a Zenpower or AMD/Intel CPU and set the correct path for the RAPL energy counter.*

3. run ```./querysetup.sh``` it will install script that will provide the energy consumption data to the web interface.

4. run ```./injector.sh``` it will inject the patch into the pve-manager index.html template file.


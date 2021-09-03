# Monitor and visualize the validators metrics
While all the programs will work, there is no auto dashboard import (yet).
The firewall rules will open tcp/3000, the default grafana dashboard, and the default user and pass will owrk (admin/admin).
The dashboard .json file is included, but must set up manually if needed for the moment.

If you don't need Grafana:
 - delete the Grafana user creation and binary download
 - remove the service file copy
 - remove port opening from firewall

If you are not just playing on the testnet, a separate monitoring system would be nice, which is not running on this node and send you alerts if your node is offline.

# Alerts

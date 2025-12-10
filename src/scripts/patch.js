Ext.ClassManager.onCreated('PVE.qemu.Summary', function() {
    Ext.define("pve-qemu-power-summary", {
        override: "PVE.qemu.Summary",

        initComponent: function() {
            let me = this;
            me.callParent();

            console.log("Power patch active for VM:", me.pveSelNode.data.vmid);

            // after the summary box renders
            me.on("afterrender", function() {
                let vmid = me.pveSelNode.data.vmid;

                Proxmox.Utils.API2Request({
                    url: "/nodes/" + Proxmox.NodeName + "/qemu/" + vmid + "/status/current",
                    method: "GET",
                    waitMsgTarget: me,
                    success: function() {
                        Proxmox.Utils.run_command(
                            ["/usr/local/bin/powerquery.sh", vmid],
                            function(response) {
                                try {
                                    let data = JSON.parse(response);
                                    let watts = data.watts + " W";
                                    let kwh = data.kwh + " kWh";

                                    // append to Summary Info box
                                    me.down("#info").add({
                                        xtype: "box",
                                        html: '<div style="padding:2px 0;padding-left:6px;">' +
                                              '<b>Power:</b> ' + watts + 
                                              '  |  <b>KWH:</b> ' + kwh +
                                              '</div>'
                                    });

                                    console.log("Power info added for VM:", vmid);
                                } catch (e) {
                                    console.warn("Power patch JSON parse error:", e);
                                }
                            }
                        );
                    },
                    failure: function(response) {
                        console.warn("Power patch API request failed:", response);
                    }
                });
            });
        }
    });
    console.log("Patch defined: pve-qemu-power-summary");
});

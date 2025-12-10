(function() {
    function addPowerPatch() {
        if (!Ext.ClassManager.get('PVE.qemu.Summary')) {
            // Retry after a short delay if the class doesn't exist yet
            setTimeout(addPowerPatch, 500);
            return;
        }

        Ext.define("pve-qemu-power-summary", {
            override: "PVE.qemu.Summary",

            initComponent: function() {
                let me = this;
                me.callParent();

                console.log("Patch active for VM:", me.pveSelNode?.data?.vmid || "unknown");

                me.on("afterrender", function() {
                    let vmid = me.pveSelNode?.data?.vmid;
                    if (!vmid) return;

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
                                        me.down("#info")?.add({
                                            xtype: "box",
                                            html: '<div style="padding:2px 0;padding-left:6px;">' +
                                                  '<b>Power:</b> ' + data.watts + ' W' +
                                                  ' | <b>KWH:</b> ' + data.kwh + ' kWh' +
                                                  '</div>'
                                        });
                                        console.log("Power info added for VM:", vmid);
                                    } catch (e) {
                                        console.warn("Patch JSON error:", e);
                                    }
                                }
                            );
                        },
                        failure: function(resp) {
                            console.warn("Patch API failed:", resp);
                        }
                    });
                });
            }
        });

        console.log("Patch defined: pve-qemu-power-summary");
    }

    addPowerPatch();
})();

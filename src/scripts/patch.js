Ext.define("pve-qemu-power-summary", {
  override: "PVE.qemu.Summary",
  initComponent: function () {
    let me = this;
    me.callParent();

    // add custom row after VM info loads
    me.on("afterrender", function () {
      let vmid = me.pveSelNode.data.vmid;

      Proxmox.Utils.API2Request({
        url: "/nodes/" + Proxmox.NodeName + "/qemu/" + vmid + "/status/current",
        method: "GET",
        waitMsgTarget: me,
        success: function () {
          Proxmox.Utils.run_command(
            ["/usr/local/bin/powerquery.sh", vmid],
            function (response) {
              try {
                let data = JSON.parse(response);
                let watts = data.watts + " W";
                let cost = "$" + data.cost + " /month";

                // append to Summary Info box
                me.down("#info").add({
                  xtype: "box",
                  html:
                    '<div style="padding:2px 0;padding-left:6px;"><b>Power:</b> ' +
                    watts +
                    "  |  <b>Cost:</b> " +
                    cost +
                    "</div>",
                });
              } catch (e) {}
            }
          );
        },
      });
    });
  },
});

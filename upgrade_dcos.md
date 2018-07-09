**Upgrade DCOS** 
-----
*Example, `v1.10.7 >>> v1.11.1`*

For upgrading the steps are: 

1. SSH to bootstrap node and cleanup space if required by removing older installer and tar:

```cd ~ ; rm -rf *.tar *.sh ~/genconf/serve/ ~/genconf/cluster* ~/genconf/state/*```

2. Clean up docker volumes if required (optional):

`systemctl stop docker`
`rm -rf /var/lib/docker/*`
`systemctl start docker`


3. Run the Nginx server

`sudo docker run -d -p <your-port>:80 -v $PWD/genconf/serve:/usr/share/nginx/html:ro nginx`

4. Match the config.yaml to the current version (sample attached in repo)

5. Download the current installer `dcos_generate_config.ee.sh` Generate the config with below command where the version is the present (older) version not the new where we want to upgrade to!

`dcos_generate_config.ee.sh --generate-node-upgrade-script 1.10.7`


6. Use the url for downloading the upgrade script, it will be something like this one-
`curl -O http://<bootstrap-ip>/upgrade/b1989797fc91461ab4c9f4ffd64aa4bc/dcos_node_upgrade.sh`

7. Download in all the nodes and Run the upgrade with below command, first in the master server and then after a while in the Agent nodes after the Master nodes are up.
`sudo bash ./dcos_node_upgrade.sh`

_________________

1.  Validate the upgrade:
    
    -   Verify that  `curl http://<dcos_agent_private_ip>:5051/metrics/snapshot`  has the metric  `slave/registered`  with a value of  `1`.
    -   Monitor the Mesos UI to verify that the upgraded node rejoins the DC/OS cluster and that tasks are reconciled (`http://<master-ip>/mesos`). If you are upgrading from permissive to strict mode, this URL will be  `https://<master-ip>/mesos`.

## [](https://docs.mesosphere.com/1.11/installing/ent/upgrading/#troubleshooting-recommendations)Troubleshooting Recommendations

The following commands should provide insight into upgrade issues:

### [](https://docs.mesosphere.com/1.11/installing/ent/upgrading/#on-all-cluster-nodes)On All Cluster Nodes

```bash
sudo journalctl -u dcos-download
sudo journalctl -u dcos-spartan
sudo systemctl | grep dcos

```

If your upgrade fails because of a  [custom node or cluster check](https://docs.mesosphere.com/1.11/installing/ent/custom/node-cluster-health-check/#custom-health-checks), run these commands for more details:

```bash
dcos-diagnostics check node-poststart
dcos-diagnostics check cluster

```

### [](https://docs.mesosphere.com/1.11/installing/ent/upgrading/#on-dcos-masters)On DC/OS Masters

```bash
sudo journalctl -u dcos-exhibitor
less /opt/mesosphere/active/exhibitor/usr/zookeeper/zookeeper.out
sudo journalctl -u dcos-mesos-dns
sudo journalctl -u dcos-mesos-master

```

### [](https://docs.mesosphere.com/1.11/installing/ent/upgrading/#on-dcos-agents)On DC/OS Agents

```bash
sudo journalctl -u dcos-mesos-slave

```

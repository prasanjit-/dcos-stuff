**DCOS Cluster Advanced Installation Steps:**

DCOS Custer will have following Nodes:
- Boot-strap Node (For managing and building the cluster & its artifacts)
-   Master Nodes (Mesos Masters)
-   Private Agent Nodes (Mesos Public Slave)
-   Public Agent Nodes (Mesos Private Slave)

A.	Install the prerequisites by running the below shell script on all servers:

    sudo bash install_prerequisites.sh

3. Generate password Hash and populate it in config .yaml

    sudo bash dcos_generate_config.ee.sh --hash-password <superuser_password>

4.Create a configuration file and save as genconf/config.yaml (sample added in repo)
config.yaml

The structure of genconf looks like this now-
-   A  `genconf/config.yaml`  file that is optimized for manual distribution of DC/OS across your nodes.
-   A  `genconf/license.txt`  file containing your DC/OS Enterprise license.
-   A  `genconf/ip-detect`  script.

**To install DC/OS:**

1.  From the bootstrap node, run the DC/OS installer shell script to generate a customized DC/OS build file. The setup script extracts a Docker container that uses the generic DC/OS install files to create customized DC/OS build files for your cluster. The build files are output to  `./genconf/serve/`.
    
    **Tip:**  You can view all of the automated command line installer options with the  `dcos_generate_config.ee.sh --help`  flag.
    
    ```bash
    sudo bash dcos_generate_config.ee.sh
    
    ```
    
    At this point your directory structure should resemble:
    
    ```undefined
    ├── dcos-genconf.c9722490f11019b692-cb6b6ea66f696912b0.tar
    ├── dcos_generate_config.ee.sh
    ├── genconf
    │   ├── config.yaml
    │   ├── ip-detect
    │   ├── license.txt
    
    ```
    
    **Tip:**  For the install script to work, you must have created  `genconf/config.yaml`  and  `genconf/ip-detect`.
    
2.  From your home directory in boot-strap node, run this command to host the DC/OS install package through an NGINX Docker container. For  `<your-port>`, specify the port value that is used in the  `bootstrap_url`.
    
    ```bash
    sudo docker run -d -p <your-port>:80 -v $PWD/genconf/serve:/usr/share/nginx/html:ro nginx
    
    ```    

3.  Run these commands on each of your master nodes in succession to install DC/OS using your custom build file.
    
    **Tip:**  Although there is no actual harm to your cluster, DC/OS may issue error messages until all of your master nodes are configured.
    
    1.  SSH to your master nodes:
        
        ```bash
        ssh <master-ip>
        
        ```
        
    2.  Make a new directory and navigate to it:
        
        ```bash
        mkdir /tmp/dcos && cd /tmp/dcos
        
        ```
        
    3.  Download the DC/OS installer from the NGINX Docker container, where  `<bootstrap-ip>`  and  `<your_port>`  are specified in  `bootstrap_url`:
        
        ```bash
        curl -O http://<bootstrap-ip>:<your_port>/dcos_install.sh
        
        ```
        
    4.  Run this command to install DC/OS on your master nodes:
        
        ```bash
        sudo bash dcos_install.sh master
        
        ```
        
4.  Run these commands on each of your agent nodes to install DC/OS using your custom build file.
    
    1.  SSH to your agent nodes:
        
        ```bash
        ssh <agent-ip>
        
        ```
        
    2.  Make a new directory and navigate to it:
        
        ```bash
        mkdir /tmp/dcos && cd /tmp/dcos
        
        ```
        
    3.  Download the DC/OS installer from the NGINX Docker container, where  `<bootstrap-ip>`  and  `<your_port>`  are specified in  `bootstrap_url`:
        
        ```bash
        curl -O http://<bootstrap-ip>:<your_port>/dcos_install.sh
        
        ```
        
    4.  Run this command to install DC/OS on your agent nodes. You must designate your agent nodes as  [public](https://docs.mesosphere.com/1.11/overview/concepts/#public)or  [private](https://docs.mesosphere.com/1.11/overview/concepts/#private).
        
        -   Private agent nodes:
            
            ```bash
            sudo bash dcos_install.sh slave
            
            ```
            
        -   Public agent nodes:
            
            ```bash
            sudo bash dcos_install.sh slave_public
            
            ```
            
    
    **Tip:**  If you encounter errors such as  `Time is marked as bad`,  `adjtimex`, or  `Time not in sync`in journald, verify that Network Time Protocol (NTP) is enabled on all nodes. For more information, see the  [system requirements](https://docs.mesosphere.com/1.11/installing/ent/custom/system-requirements/#port-and-protocol).
    
5.  Monitor Exhibitor and wait for it to converge at  `http://<master-ip>:8181/exhibitor/v1/ui/index.html`.
    
    **Tip:**  This process can take about 10 minutes. During this time you will see the Master nodes become visible on the Exhibitor consoles and come online, eventually showing a green light.
    

[![Exhibitor for ZooKeeper](https://docs.mesosphere.com/1.11/img/chef-zk-status.png)](https://docs.mesosphere.com/1.11/img/chef-zk-status.png)

_Figure 1 - Exhibitor for ZooKeeper_

When the status icons are green, you can access the DC/OS web interface.

7.  Launch the DC/OS web interface at:  `http://<master-node-public-ip>/`.
    
    **Important:**  After clicking  **Log In To DC/OS**, your browser may show a warning that your connection is not secure. This is because DC/OS uses self-signed certificates. You can ignore this error and click to proceed.
    
8.  Enter your administrator username and password.
    

[![Login screen](https://docs.mesosphere.com/1.11/img/ui-installer-auth2.png)](https://docs.mesosphere.com/1.11/img/ui-installer-auth2.png)

_Figure 2 - Login screen_

You are done! The UI dashboard will now be displayed.

[![UI dashboard](https://docs.mesosphere.com/1.11/img/dashboard-ee.png)](https://docs.mesosphere.com/1.11/img/dashboard-ee.png)

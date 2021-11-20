# Nextcloud hosting on Always-free tier Oracle Cloud (OCI)

Oracle Cloud (OCI) is offering a generous "Always-free tier" including several CPU cores/instances, 24GB(!) memory and 200GB of block storage. Deploying Nextcloud on this offering works really well.

- I have decided on a single VM deployment with a docker daemon. My focus was on maximising performance and storage instead of high-availability. Each VM boot volume would consume at least 50GB. As we only get 200GB for free, I have chose a single instance compared to e.g. a multi-node k3s cluster.  
- Terraform for both the cloud infrastructure and the deplyoment on the docker daemon.
- Object Storage bucket included which can be integrated with Nextcloud's external storage plugin. We get 20GB for free.
- Bastion host setup included to access the VM over ssh in a private subnet.

## Instructions

The deployment of the architecture has to be performed in two steps: first the OCI infrastructure and then the docker deployments on te OCI VM instance.

### OCI infrastructure

Run terraform in the `oci` subfolder. With the output variables (`bastion_session_id, instance_private_ip`) you will be able to `ssh` into the instance. Use a `ssh config` like this:

```text
Host oci
 HostName <instance_private_ip>
 User ubuntu
 Port 22
 IdentityFile /home/you/.ssh/id_rsa_oci 
 ProxyCommand ssh -i /home/you/.ssh/id_rsa_oci -W %h:%p -p 22 <bastion_session_id>
 ```

### VM instance / Docker host

Run terraform in the `docker` subfolder. Terraform will use the `ssh` connection you have previously configured. 

The output variables include your Nextcloud admin password and the commands you need to perform to set up the MariaDB database.

You need to restart Nextcloud such that it will be able to establish a connection with the database and finish the installation process: `docker restart nextcloud`.

The Traefik container is listening on port `80` and `443`. Because the OCI load balancer needs some time to consider the ports as healthy, you also need to `docker restart traefik`. Only with a healthy status (on port `80` will Traefik be able to generate a letsencrypt certificate).  

### Nextcloud config: External Storage plugin for OCI Object storage

In the Nextcloud web interface, add two Apps from the standard catalog: "External storage support" and "S3 Versioning". 
- In the Nextcloud settings, go to the general configuration of the "external storage" plugin.
- Fill in the configuration for the object store/bucket by using the terraform output variables. See [this screenshot](/images/nextcloud_oci_object_storage.png) how the variables are mapped. 

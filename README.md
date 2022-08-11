# olm-auto - BETA version :) Linux Dependent
# Intro
This playbook is designed to create a data folder for internal registry at the restricted network environment.

> @bvaturi add youtube recording


# Before Running the playbook
0. Access: https://console.redhat.com/openshift/install/pull-secret and download a pull-secret.json file to `/tmp/pull-secret.json`
   
   Also do the next command and enter your credentials:
   sudo podman login registry.redhat.io
 

1. Make sure you have enough space available on the disk (more than 50GB)
   *** If you use partitions make sure /var have at least 5GB and other memory is at /

2. Run:
```bash
sudo ansible-galaxy collection install community.crypto
sudo ansible-galaxy collection install containers.podman
sudo ansible-galaxy collection install community.general
```

3. Run the playbook as `root` 

4. The playbook will create:

    i. data_<operator_name>.tar.gz file at extfiles
  
    ii.  latest `oc` binary
    iii. latest `opm` binary
    iv.  `grpcurl`
    v.   `kubectl`
  
    iii. A `manifests_<operator_name>` file at the `run` directory (where you ran the playbook)


  
## changeable params:
1. _ocpver_
    this is the parameter that define what openshift cluster version is needed, ie: v4.8

2. _index_image_
     Choose one of the following: redhat-operator/certified-operator/community-operator


# Post run

1. un-tar the data.tar.gz
`tar -zxvf data_<operator_name>.tar.gz`

2. start your local registry

3. create a softlink for local registry data file --> data_<operator_name>

4. restart the registry container

> @bvaturi add youtube recording


5. Now you have a registry with the data on it. please check:

```bash
curl -u admin:redhat -k https://${Local_registry}:5000/v2/_catalog 
```

> You will see the output with all the images.

5. Please push the images to your artifactory / registry

6. change the image content policy and the catalog source to point to YOUR registry / artifactory

7. Apply the image content policy and the catalog from the manifest folder.   
```bash
oc apply -f <the files> 
```

# TODO
1. V2 - In case the user of the automation wants to mirror multiple operators, generate each of them an index image so they will be decoupled when deployed on OCP

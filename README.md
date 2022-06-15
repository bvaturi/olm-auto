# olm-auto - BETA version :)

# Before Running the playbook

1. make sure you can login to the desired registry (down below) with a Rehat account
2. make sure you have enough space available on the disk (more than 50GB)
  i. log in to it
3. please install:
```
sudo ansible-galaxy collection install community.crypto
sudo ansible-galaxy collection install containers.podman
sudo ansible-galaxy collection install community.general
```
4. some tasks require root, please make sure you can run as root if needed

5. the playbook will create
  i. data.tar.gz file at extfiles
  ii. it will download the latest oc bin, please add that too
  iii. a manifest file at the run directory (where you ran the playbook), please add that too
6. there is a script - registry_two_script.sh - please copy it.
   this will be the internal registry you will need.
   load the data file to the location that needed (take a look at the script).
   once configured - you will have an internal registry that will hold all the needed images of the operators

##changeable params:
imagelist: "kiali-ossm"       --> this is the operator that needed, you need to give full name as displayed in redhat index.
                              --> you can add multiple operators from the same index, but full name is required
                              --> example: "jaeger-product, kiali-ossm, elasticsearch-operator, servicemeshoperator"
                    
ocpver:  "v4.8".              --> Openshift version
rhindex: "registry.redhat.io" --> red hat index
                              --> "certified-operator-index" 
                              --> "redhat-marketplace-index"
                              --> "community-operator-index"

this playbook is designed to create a data folder for internal registry at the restricted network environment.

## Before you begin you need to understand what operators you want:

please install podman ( or any container engine you want)

please install grpcurl:
```wget https://github.com/fullstorydev/grpcurl/releases/download/v1.8.6/grpcurl_1.8.6_linux_x86_64.tar.gz```

```
podman run -p50051:50051 -d -it registry.redhat.io/redhat/<redhat index>:<openshifr cluster version>
grpcurl -plaintext localhost:50051 api.Registry/ListPackages > packages.out
vim packages.out
```

# Post run

1. un-tar the data.tar.gz
`tar -zxvf data.tar.gz`

2. start the local registry 
   make sure you run the script at a directory that has enough space on the disk (more the 50GB)

```
chmod +x registry_two_script.sh
bash registry_two_script.sh
```

3. (Beta and needed to be fixed)
   it might not load the data folder, please edit the script and remove the mkdir commads, because the files are already there, and then run the script again
   
4. now you have a registry with the data on it. please check:

``` curl -u admin:redhat -k https://${REGISTRYTWO_FQDN}:5001/v2/_catalog ```

you will see the output with all the images.

5. please push the images to your artifactory / registry
6. apply the image content policy and the catalog from the manifest folder.
   ``` oc apply -f <the files> ```

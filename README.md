# olm-auto - BETA version :)

# Intro
This playbook is designed to create a data folder for internal registry at the restricted network environment.

> @bvaturi add youtube recording


# Before Running the playbook
0. Access: https://console.redhat.com/openshift/install/pull-secret and download a pull-secret.json file to `/tmp/pull-secret.json`

1. Make sure you have enough space available on the disk (more than 50GB)

2. Run:
```bash
sudo ansible-galaxy collection install community.crypto
sudo ansible-galaxy collection install containers.podman
sudo ansible-galaxy collection install community.general
```

3. Run the playbook as `root` 

4. The playbook will create:

    i. data.tar.gz file at extfiles
  
    ii. latest `oc` binary
    > @bvaturi it to the data.tar.gz
  
    iii. A `manifests` file at the `run` directory (where you ran the playbook)
    > @bvaturi it to the data.tar.gz

5. registry_two_script.sh:

* This will be the internal registry you will need.
load the data file to the location that needed (take a look at the script).

* once configured - you will have an internal registry that will hold all the needed images of the operators .
> @bvaturi it to the data.tar.gz

  
## changeable params:
1. _imagelist_ 
    > @bvaturi Add short explainer
2. _ocpver_
    > @bvaturi Add short explainer
3. _rhindex_
    > @bvaturi Add short explainer


## Before you begin you need to understand what operators you want:
> @bvaturi Remove once done

please install podman ( or any container engine you want)
> @bvaturi Put it in the playbook

please install grpcurl:
```wget https://github.com/fullstorydev/grpcurl/releases/download/v1.8.6/grpcurl_1.8.6_linux_x86_64.tar.gz```
> @bvaturi Put it in the playbook

```
podman run -p50051:50051 -d -it registry.redhat.io/redhat/<redhat index>:<openshifr cluster version>
grpcurl -plaintext localhost:50051 api.Registry/ListPackages > packages.out
vim packages.out
```
> @bvaturi Put it in the playbook

# Post run

1. un-tar the data.tar.gz
`tar -zxvf data.tar.gz`

2. start the local registry 
   make sure you run the script at a directory that has enough space on the disk (more the 50GB)

```bash
chmod +x registry_two_script.sh
bash registry_two_script.sh
```

> @bvaturi add the softlink + restart container

> @bvaturi add youtube recording


3. (Beta and needed to be fixed)
   it might not load the data folder, please edit the script and remove the mkdir commads, because the files are already there, and then run the script again
> @bvaturi delete once done

4. Now you have a registry with the data on it. please check:

```bash
curl -u admin:redhat -k https://${REGISTRYTWO_FQDN}:5001/v2/_catalog 
```

> You will see the output with all the images.

5. Please push the images to your artifactory / registry
6. Apply the image content policy and the catalog from the manifest folder.   
```bash
oc apply -f <the files> 
```

# TODO
1. Make the variable `imagelist` in the playbook to be of type `like` query instead of `exact`
2. Delete unused vars from playbook 
3. @tommeramber add redhat login too all RH registries
4. grpcurl - adjust for a single operator
5. Soft link + restart in internal netowkr + run.sh with oc mirror commands to internal registry
6. V2 - In case the user of the automation wants to mirror multiple operators, generate each of them an index image so they will be decoupled when deployed on OCP

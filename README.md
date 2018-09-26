# sigsci-cloud-kube

Helper script for deploying the Signal Sciences reverse proxy agent in a Kubernetes cluster.

[![Build Status](https://travis-ci.org/foospidy/sigsci-cloud-kube.svg?branch=master)](https://travis-ci.org/foospidy/sigsci-cloud-kube)

This is ideal to use as a template and modify to your needs. Current cloud provider support is Google Cloud and IBM Cloud.

More providers to be added.

## Basic Usage

```bash
# export needed variables
export SIGSCI_GCLOUD_PROJECT=myproject-1234
export IBMCLOUD_REGISTRY_NAMESPACE=signalsciences
export SIGSCI_ACCESSKEYID=abcd
export SIGSCI_SECRETACCESSKEY=1234
export SIGSCI_REVERSE_PROXY_UPSTREAM=myapp-1234.appspot.com

# Create a new cluster on cloud providers
./sigsci-cloud-kube -C ibmcloud gcloud -c sigsci0

# Push container image to cloud provider container registry
./sigsci-cloud-kube -str ibmcloud gcloud

# Deploy Signal Sciences to cluster on cloud providers
./sigsci-cloud-kube -d ibmcloud gcloud -c sigsci0

# Expose Signal Sciences service on cloud providers
./sigsci-cloud-kube -e ibmcloud gcloud -c sigsci0
```

## Resource Links

IBM Cloud

- todo

Google Cloud

- todo

AWS

- https://medium.com/containermind/how-to-create-a-kubernetes-cluster-on-aws-in-few-minutes-89dda10354f4
- https://aws.amazon.com/fargate/

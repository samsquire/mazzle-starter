# devops-pipeline-starter

This project provisions a real life infrastructure using [devops-pipeline](https://github.com/samsquire/devops-pipeline). This project uses [platform-up](https://github.com/samsquire/platform-up) to test ansible playbooks.

![Pipeline](architecture.png)

# Documentation

This is documentation by component:

## ansible/worker-provision

Provisions worker machines with tools. Generates SSH keys for workers.

## ansible/worker-keys

Provisions all other servers with worker keys, so ansible can be run from the workers.

## ansible/devbox

Provisions master machine with same tools as the cloud boxes.

## terraform/services

Ties together all the DNS records for prometheus and produces a cluster output which is a list of all the machines

## gradle/app

Builds a spring boot hello world application

## ansible/deploy

Deploys a spring boot application as a service. Depends on the artifact produced by gradle/app

## ansible/kubernetes-join

Causes the cluster to join the kubernetes master on the first worker

## terraform/bastion

Provisions a bastion server

## ansible/kubernetes

Installs a kubernetes master with kubeadm

## ansible/consul

Provisions a consul server

## ansible/consul-cluster

Provisions consul on all the other boxes.

## shell/init-vault

Logs into bastion and initializes the vault. Capturing the secrets as a secrets output which are then encrypted by your GPG key.

## ansible/machines

Spins up two CI machines

## repository-upload/node

# Contents

* Debian package repository server
* 2 CI build machines
* Prometheus instance for monitoring, monitoring via DNS
* Node exporter installed on base AMI
* Hashicorp Vault with Self signed Certificate authority for TLS
* bastion
* Kubernetes clustering


# Notes

 * DEBian packages can be uploaded to the repository with the repository-upload provider.
 * SSH keys are generated on each worker and provisioned onto every other node by ansible/playbooks/worker-keys
 * Kubernetes is installed on the cluster of bastion, web, prometheus, vault servers
 * Instances have a volume service which mount volumes using the instance tags -- rather than using Terraform.

# Expanded lifecycle pipeline

Look carefully and you'll see the expanded pipeline below:
![ExpandedPipeline](architecture.expanded.png)
It's so large you have to look carefully.

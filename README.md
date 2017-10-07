# fun infra

This is an experimental infrastructure to demonstrate the tool [devops-pipeline](https://github.com/samsquire/devops-pipeline).

![Pipeline](architecture.png)

# Contents

* Prometheus instance for monitoring, monitoring via DNS
* Node exporter installed on base AMI
* Hashicorp Vault with Self signed Certificate authority for TLS
* bastion

# Notes

 * Instances have a volume service which mount volumes using the instance tags -- rather than using Terraform. 

# Todo

* Centralised logging 
* Put Prometheus on its own box
* Audit

# Expanded pipeline


![ExpandedPipeline](architecture.expanded.png)

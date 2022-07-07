# Azure hub-spoke architecture with terraform

## Usage

```
terraform init
terraform plan --out main.tfplan
terraform apply main.tfplan
```

## Destroy

```
terraform plan -destroy -plan main.destroy.plan
terraform apply main.destroy.plan
```

## Networks

### Nodes hub

- 10.0.0.0/16

Gateway - 10.0.230.0/24
Firewall - 10.0.240.0/20
Bastion - 10.0.0.0/26
Mgmt - 10.0.0.64/27

#### Kava node

- 10.1.1.0/24

Workload - 10.1.1.64/27

### Infra hub

- 10.230.0.0/17

Bastion - 10.230.0.0/26
Firewall - 10.0.240.0/20

### Mntr spoke

Storage account - 10.230.252.0/22

Internal mntr - 10.230.132.0/22
External mntr - 10.230.152.0/22

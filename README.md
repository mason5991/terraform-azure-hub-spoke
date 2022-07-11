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

Vnet - 10.0.0.0/16

- Gateway - 10.0.230.0/24
- Firewall - 10.0.240.0/20
- Bastion - 10.0.0.0/26
- Mgmt - 10.0.0.64/27

#### Kava node

Vnet - 10.1.1.0/24

- Workload - 10.1.1.64/27

### Main hub

Vnet - 10.255.0.0/16

- Bastion - 10.255.255.0/24
- Firewall - 10.255.0.0/20
- Vpn gateway - 10.255.250.0/24
- Mgmt - 10.255.254.0/24

#### Monitoring spoke

Vnet - 10.250.0.0/17

- Storage account - 10.250.124.0/22

- Monitoring internal - 10.250.0.0/22
- Monitoring external - 10.250.64.0/22

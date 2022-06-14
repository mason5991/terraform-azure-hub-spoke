# Azure hub-spoke architecture with terraform

## Usage

```
terraform init
terraform plan --out main.tfplan
terraform apply main.tfplan
```

## Remove

```
terraform plan -destroy -plan main.destroy.plan
terraform apply main.destroy.plan
```

# aks-terraform-example

This is an example Infrastructure as Code (IaC) project using Docker and Terraform to provision and deploy an example application on Azure Kubernetes Service (AKS).

## Build and run the Docker Container

This project provides a lightweight Alpine Linux Docker image, pre-installed with [Terraform](https://github.com/hashicorp/terraform/releases), [kubectl](https://github.com/kubernetes/kubernetes/releases), and [azure-cli](https://github.com/Azure/azure-cli/releases).
```bash
# Build the image
$ docker build -t aks-terraform-example .

...

# Run the image - works with Powershell or Bash
$ docker run --rm -it ${PWD}:/code aks-terraform-example bash 
```

# Cleaning up

## Destroying resources with Terraform

## Cleaning up Docker
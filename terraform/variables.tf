# Tags for created resources
variable "environment" {
    default = "Development"
}

variable "location" {
    default = "East US"
}

# Read from environment with TF_VARS_
variable "client_id" {}
variable "client_secret" {}
variable "tentant_id" {}
variable "subscription_id" {}

## k8s specific stuff here
# Increase for a production scenario
variable "agent_count" {
    default = 1
}
variable "kubernetes_version" {
    default = "1.17.3"
}
variable "dns_prefix" {
    default = "akstfexample"
}
variable "resource_group_name" {
    default = "aks-terraform-example"
}
variable "ssh_authorized_key" {
    default = "~/.ssh/id_rsa.pub"
}
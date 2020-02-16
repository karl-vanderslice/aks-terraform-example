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

From here out, you can work inside the container shell.

## Provisioning an AKS Cluster

### Authenticating with Azure

```bash
$ az login
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code ABCDEFGHI to authenticate.

[
  {
    "cloudName": "AzureCloud",
    "id": "FFFFFFF-2eea-41f7-a76a-31b77679f47f",
    "isDefault": true,
    "name": "Azure subscription 1",
    "state": "Enabled",
    "tenantId": "FFFFFFF-d5ac-4e98-adb0-bb345c066fb7",
    "user": {
      "name": "art@vandelayindustries.com",
      "type": "user"
    }
  }
]                                                       
```

Note the `"id"` field from the above command.  This will be used later when setting Terraform variables.

### Create the Azure Service Principal

Substitute your Subscription ID (`"id"` from above) in the scopes parameter:

```bash
$ az ad sp create-for-rbac -n "aks-terraform-demo-sp" --role contributor --scopes "/subscriptions/FFFFFFF-2eea-41f7-a76a-31b77679f47f"
Changing "aks-terraform-demo-sp" to a valid URI of "http://aks-terraform-demo-sp", which is the required format used for service principal names
Creating a role assignment under the scope of "/subscriptions/FFFFFFF-2eea-41f7-a76a-31b77679f47f"

  Retrying role assignment creation: 1/36
  Retrying role assignment creation: 2/36

{
  "appId": "FFFFFFF-28a7-4d2d-9413-48a1498e7e76",
  "displayName": "aks-terraform-demo-sp",
  "name": "http://aks-terraform-demo-sp",
  "password": "FFFFFFF-61ab-4700-9279-a5094b179fab",
  "tenant": "FFFFFFF-a279-4836-b6b3-cdb16101d5a6"
}
```

Note the `"appId"`, `"password"`, and `"tenant"` values from the above command output.  These will be used later when setting Terraform variables.

### Configure Terraform Variables

To keep the Terraform code clean and the configuration ephemeral, configure the Terraform variables in the shell:

```bash
$ export TF_VAR_client_id=<SP appId>
$ export TF_VAR_client_secret=<SP password>
$ export TF_VAR_tenant_id=<SP tenant>
$ export TF_VAR_subscription_id=<Subscription ID>
```

These are the values noted from the commands above.

### Generate a SSH keypair

Lastly, generate a keypair for connecting to the cluster:

```shell
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Created directory '/root/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa.                  
Your public key has been saved in /root/.ssh/id_rsa.pub.                       
```

### Initializing and running Terraform plan

Change directory to the `terraform/` directory and initialize Terraform:

```bash
$ cd terraform/
$ terraform init

Initializing the backend...

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Run `terraform plan` to check what will be created:

```bash
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_kubernetes_cluster.k8s will be created
  + resource "azurerm_kubernetes_cluster" "k8s" {

      ...

```

## Creating the AKS cluster with Terraform Apply

Once you have validated your Terraform plan, apply the code:

```bash
$ terraform apply
```

After a few minutes, your cluster will be up and running.  Note the values of the outputs above.  They aren't required, but are good to use as a reference if needed.  You can reference them later from the state file by issuing `terraform output` or `terraform output -json | jq -r` for a more readable version.

## Configuring kubectl and query the cluster

Configure `kubectl` to use our created cluster:

```shell
$ az aks get-credentials -n aks-terraform-demo -g aks-terraform-example
Merged "aks-terraform-demo" as current context in /root/.kube/config
```

Query the cluster status:

```shell
$ kubectl cluster-info
Kubernetes master is running at https://akstfexample-FFFFFFF.hcp.eastus.azmk8s.io:443
CoreDNS is running at https://akstfexample-FFFFFFF.hcp.eastus.azmk8s.io:443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://akstfexample-FFFFFFF.hcp.eastus.azmk8s.io:443/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy
```

## Running a sample application

The example [`echo-application.yml`](echo-application.yml) manifest uses the Hashicorp [http-echo]() image:

```shell
$ kubectl apply -f echo-application.yml
deployment.apps/echo-app created
service/echo-app created
```

Verify the deployment:

```shell
$ kubectl get deployments
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
echo-app   1/1     1            1           3m2s
```

Verify the service:

```shell
$ kubectl get services
NAME         TYPE           CLUSTER-IP   EXTERNAL-IP     PORT(S)          AGE
echo-app     LoadBalancer   10.0.11.89   1.1.1.1         5678:31530/TCP   3m6s
kubernetes   ClusterIP      10.0.0.1     <none>          443/TCP          36m
```

## Test connectivity to our deployed service

Using the `EXTERNAL-IP` of the `echo-app` above:

```shell
$ curl http://1.1.1.1:5678
'Hello from Azure Kubernetes Service!'
```

# Cleaning up

## Removing the deployed service

Remove the published `echo-app` manifest:

```shell
$ kubectl delete -f echo-application.yml
deployment.apps "echo-app" deleted
service "echo-app" deleted
```

## Destroying resources with Terraform

From the `terraform/` directory:

```shell:
$ terraform destroy
```

After a few minutes, the cluster will be destroyed.

## Removing azure-cli created resources

Remove the Service Principal from the Azure account:

```shell
$ az ad sp delete --id FFFFFFF-28a7-4d2d-9413-48a1498e7e76
```

The `id` parameter is the same as the Service Principal "`appId`"

## Cleaning up Docker

Exit the container and prune the Docker system _(note that this will delete other images on your system, so use with care.)_

```shell
$ exit
$ docker system prune -f -a
```

Verify the cleanup with `docker system df`.
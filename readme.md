# Deploy an image to Azure Cloud using Packer and Terraform #

1. Clone this repo to your local directory.
2. You will need to have an Azure account, Azure CLI, Packer and Terraform installed.


# Packer Instructions #
1. Replace the Azure items as listed **Tenant ID, Subscription ID, resource group and any other accounts as needed.**
2. Update the server.json as needed with the items you want Packer to install before it creates your image. Specifically the builders section is where you need to add these items.


# Terraform #
1. Update the Terraform main.tf using your variables as needed, Azure CIDR range and any other items as necessary.
2. The **vars.tf** file can be change to add variables before the build. Following the format you can create variables that will be passed to the **maint.tf**.

example: variable "input" {
  description = "This will create a variable called input and can be passed to the main.tf"


# Other Links #
These links will assist you with using the DevOps tools used in this build.

- https://Terraform.io
- https://packer.io
- https://docs.microsoft.com/en-us/azure/?product=featured



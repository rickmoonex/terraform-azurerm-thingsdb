# terraform-azurerm-thingsdb

A Terraform module for quickly deploying a single-node ThingsDB environment on Azure Container Instances.

This module deploys Caddy as a sidecar proxy for securing the HTTP and WebSocket API with a TLS certificate that is created by Let's Encrypt.

## Usage

> [!WARNING]
> Due to rate limiting issues with Docker Hub when trying to pull the Caddy image. The input of container registry credentials is necessary.
> This can be a credential for Docker Hub, or a private registry. In case of a private registry the caddy image can be changed with the `caddy_image` input.

To get started with the module you can use the following snippet:

### API



### Inputs

For further details and supported inputs please refer to the [Terraform Registry](https://registry.terraform.io/modules/rickmoonex/thingsdb/azurerm/latest?tab=inputs)

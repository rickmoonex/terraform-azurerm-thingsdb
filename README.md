# terraform-azurerm-thingsdb

A Terraform module for quickly deploying a single-node ThingsDB environment on Azure Container Instances.

This module can also deploy a Caddy as a sidecar proxy for securing the HTTP and WebSocket API with a TLS certificate that is created by Let's Encrypt.

## Usage

> [!WARNING]
> Due to rate limiting issues with Docker Hub when trying to pull the Caddy image. The input of container registry credentials is necessary.
> This can be a credential for Docker Hub, or a private registry. In case of a private registry the caddy image can be changed with the `caddy_image` input.

To get started with the module you can use the following snippet:

```hcl
resource "azurerm_resource_group" "rg" {
    name = "thingsdb-rg"
    location = "westeurope"
}

module "thingsdb" {
  source  = "rickmoonex/thingsdb/azurerm"
  version = "1.1.0"

  name = "mythingsdbdev"
  resource_group = azurerm_resource_group.rg

  # Replace these with your own credentials as mentioned above.
  registry_credential = {
    username = "user"
    password = "pass"
    server = "server"
  }
}
```

### API

To enable the HTTP/WebSocket API of ThingsDB we can add the following input to the module:

```hcl
http_api = {
    # This enables the HTTP API
    enable = true
    # This enabled the WebSocket API
    enable_websocket = true
}
```

This will start a Caddy sidecar container and serve the API at the FQDN of the conatiner group. For example: `https://mythingsdb.westeurope.azurecontainer.io`. When the WebSocket API is enabled it can be reached at `wss://<fqdn>/ws`.

To change the FQDN used in the Caddy config to your own domain name. Add the `proxy_dns_name` property to the `http_api` block.

### Inputs

For further details and supported inputs please refer to the [Terraform Registry](https://registry.terraform.io/modules/rickmoonex/thingsdb/azurerm/latest?tab=inputs)

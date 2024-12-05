variable "name" {
  type        = string
  description = "The name to use for the ThingsDB container instance."
}

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = "An object representing the resource group to deploy to."
}

variable "ip_address_type" {
  type        = string
  description = "The type of IP to assign to the container group. `Public`, `Private`, or `None`. If set to `Private`, `subnet_ids` also needs to be set."
  default     = "Public"

  validation {
    condition     = provider::assert::contains(["Public", "Private", "None"], var.ip_address_type)
    error_message = "`ip_address_type` should be either `Public`, `Private`, or `None`."
  }

  validation {
    condition     = var.ip_address_type == "Private" ? provider::assert::true(var.subnet_ids != null) : true
    error_message = "When address type is `Private`, `subnet_ids` must be set."
  }
}

variable "subnet_ids" {
  type        = set(string)
  description = "The subnet ids where the container group should connect to."
  nullable    = true
  default     = null
}

variable "dns_name_label" {
  type        = string
  description = "The DNS label/name for the container group's IP."
  nullable    = true
  default     = null
}

variable "thingsdb_version" {
  type        = string
  description = "The version of ThingsDB to use. Defaults to latest."
  nullable    = true
  default     = null
}

variable "cpu_cores" {
  type        = number
  default     = 1
  description = "The amount of CPU cores to dedicate to the ThingsDB instance."
}

variable "memory" {
  type        = number
  description = "The amount of memory in GB to dedicate to the ThingsDB instance."
  default     = 2
}

variable "client_listen_port" {
  type        = number
  description = "The port on which the ThingsDB TCP Socket should listen."
  default     = 9200
}

variable "http_api" {
  type = object({
    enable            = bool
    enable_websockets = optional(bool, false)
    allow_https       = optional(bool, true)
    allow_http        = optional(bool, false)
    proxy_dns_name    = optional(string)
  })
  default = {
    enable = false
  }
  description = "API Settings for ThingsDB."
}

variable "caddy_image" {
  type        = string
  description = "The docker image to use for Caddy. Defaults to `caddy:2.6` if left empty."
  nullable    = true
  default     = null
}

variable "storage_account_name" {
  type        = string
  description = "The name to give to the ThingsDB data storage account. If left empty a dynamic name will be generated."
  nullable    = true
  default     = null
}

variable "registry_credential" {
  type = object({
    username = string
    password = string
    server   = string
  })
  description = "Credentials to use for pushing an pulling images."
}

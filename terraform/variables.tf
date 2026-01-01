variable "proxmox_token_id" {
  type    = string
  default = "terraform-prov@pve!terraform-key"
}

variable "proxmox_api_token" {
  type      = string
  sensitive = true # hide from logs
}

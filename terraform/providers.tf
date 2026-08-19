
# Download Proxmox provider plugin
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.66.0"
    }
  }
}

# Proxmox connection details
provider "proxmox" {
  endpoint  = "https://192.168.0.153:8006/"
  insecure  = true
  api_token = "terraform-prov@pve!terraform-token=74587c9e-04a3-4372-8f41-776595f9847b"

  ssh {
    agent    = true
    username = "root"
  }
}

#!/usr/bin/env bash

# 1. Delete old terraform cache files and lock files
rm -rf .terraform .terraform.lock.hcl

# 2. Write providers.tf
cat << 'EOF' > providers.tf

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
EOF

# 3. Write main.tf
cat << 'EOF' > main.tf

# Shortcut variables
locals {
  target_node = "proxmox"
  template_id = 9000
}

# ------------------------------------------------------------------
# VM 100: k3s-main (Control Plane)
# ------------------------------------------------------------------
resource "proxmox_virtual_environment_vm" "k3s_main" {
  name      = "k3s-main"
  node_name = local.target_node
  vm_id     = 100

  clone {
    vm_id = local.template_id
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 3072 # 3.0 GB RAM
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 20
  }

  network_device {
    bridge = "localnet"
    model  = "virtio"
  }

  initialization {
    datastore_id = "local-lvm"
    interface    = "ide2"

    dns {
      servers = ["8.8.8.8", "1.1.1.1"]
    }

    user_account {
      username = "nabil"
      password = "nabil2407"
      keys     = [trimspace(file(pathexpand("~/.ssh/id_ed25519.pub")))]
    }

    ip_config {
      ipv4 {
        address = "10.10.10.100/24"
        gateway = "10.10.10.1"
      }
    }
  }
}

# ------------------------------------------------------------------
# VM 103: k3s-worker (Kubernetes Worker Node)
# ------------------------------------------------------------------
resource "proxmox_virtual_environment_vm" "k3s_worker" {
  name      = "k3s-worker"
  node_name = local.target_node
  vm_id     = 103

  clone {
    vm_id = local.template_id
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 3584 # 3.5 GB RAM (Runs app pods & containers)
  }

  disk {
    datastore_id = "Homelab-WDC-1TB"
    interface    = "scsi0"
    size         = 30
  }

  network_device {
    bridge = "localnet"
    model  = "virtio"
  }

  initialization {
    datastore_id = "Homelab-WDC-1TB"
    interface    = "ide2"

    dns {
      servers = ["8.8.8.8", "1.1.1.1"]
    }

    user_account {
      username = "nabil"
      password = "nabil2407"
      keys     = [trimspace(file(pathexpand("~/.ssh/id_ed25519.pub")))]
    }

    ip_config {
      ipv4 {
        address = "10.10.10.103/24"
        gateway = "10.10.10.1"
      }
    }
  }
}

# ------------------------------------------------------------------
# VM 101: dev-runner (GitHub Actions Runner)
# ------------------------------------------------------------------
resource "proxmox_virtual_environment_vm" "dev_runner" {
  name      = "dev-runner"
  node_name = local.target_node
  vm_id     = 101

  clone {
    vm_id = local.template_id
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2560 # 2.5 GB RAM
  }

  disk {
    datastore_id = "Homelab-WDC-1TB"
    interface    = "scsi0"
    size         = 30
  }

  network_device {
    bridge = "localnet"
    model  = "virtio"
  }

  initialization {
    datastore_id = "Homelab-WDC-1TB"
    interface    = "ide2"

    dns {
      servers = ["8.8.8.8", "1.1.1.1"]
    }

    user_account {
      username = "nabil"
      password = "nabil2407"
      keys     = [trimspace(file(pathexpand("~/.ssh/id_ed25519.pub")))]
    }

    ip_config {
      ipv4 {
        address = "10.10.10.101/24"
        gateway = "10.10.10.1"
      }
    }
  }
}

# ------------------------------------------------------------------
# VM 102: enterprise-monitoring (Prometheus + Grafana)
# ------------------------------------------------------------------
resource "proxmox_virtual_environment_vm" "enterprise_monitoring" {
  name      = "enterprise-monitoring"
  node_name = local.target_node
  vm_id     = 102

  clone {
    vm_id = local.template_id
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2560 # 2.5 GB RAM
  }

  disk {
    datastore_id = "Homelab-WDC-1TB"
    interface    = "scsi0"
    size         = 25
  }

  network_device {
    bridge = "localnet"
    model  = "virtio"
  }

  initialization {
    datastore_id = "Homelab-WDC-1TB"
    interface    = "ide2"

    dns {
      servers = ["8.8.8.8", "1.1.1.1"]
    }

    user_account {
      username = "nabil"
      password = "nabil2407"
      keys     = [trimspace(file(pathexpand("~/.ssh/id_ed25519.pub")))]
    }

    ip_config {
      ipv4 {
        address = "10.10.10.102/24"
        gateway = "10.10.10.1"
      }
    }
  }
}
EOF

# 4. Download and initialize Terraform provider dependencies
terraform init

# 5. Start SSH agent and load SSH key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 6. Clear old saved SSH host keys to avoid connection warnings
ssh-keygen -R 10.10.10.100 2>/dev/null
ssh-keygen -R 10.10.10.101 2>/dev/null
ssh-keygen -R 10.10.10.102 2>/dev/null
ssh-keygen -R 10.10.10.103 2>/dev/null

# 7. Execute destroy, plan, and create commands automatically
terraform plan
terraform apply --auto-approve

# 8. Print completion message and SSH connection hint
echo "--------------------------------------------------------"
echo "Build complete! All 4 VMs created cleanly."
echo "Wait ~30s for Cloud-Init to finish, then test connection:"
echo "ssh -J root@192.168.0.153 nabil@10.10.10.100"
echo "--------------------------------------------------------"
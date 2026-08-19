
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

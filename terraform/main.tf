terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.70.0"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://100.109.221.82:8006/"
  api_token = "${var.proxmox_token_id}=${var.proxmox_api_token}"
  insecure = true # Only if using a self-signed certificate
}

resource "proxmox_virtual_environment_vm" "vms" {
  name        = "debian-tmp-spinup"
  description = "Managed by Terraform"
  node_name   = "home-atti" 
  vm_id       = 201

  # This block is valid for VMs
  clone {
    vm_id = 8000
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  agent {
    enabled = true
    # Add this line to stop the infinite wait for an IP
    # if the guest agent isn't responding immediately
    timeout = "2m" 
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    
  user_account {
        username = "user" 
        password = "password"
        keys     = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILvScgr6BsWdu3o9XYX6h8FXf5pkeyqeHQuytFzdXUCg atticuswong@email.com",
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE0kqlHuLYDJIw/T3zi/lw7zcZsX1h2M1CfQ14UBcP7y home-atti-automation@gmail.com"
        ]
      }
  }
}

output "vm_ip" {
  # [1] targets the first interface (eth0), [0] targets the first IPv4 address
  value = proxmox_virtual_environment_vm.vms.ipv4_addresses[1][0]
}

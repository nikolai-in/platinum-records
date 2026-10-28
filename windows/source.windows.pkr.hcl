packer {
  required_plugins {
    proxmox = {
      version = "~> 1.2.4"
      source  = "github.com/hashicorp/proxmox"
    }
    windows-update = {
      version = "~> 0.18.5"
      source  = "github.com/rgl/windows-update"
    }
  }
}

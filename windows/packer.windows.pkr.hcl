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

// Windows Base Image Build Configuration (Windows 10, Server 2022, Server 2025)
//
// The Windows version is chosen with image_os; ISO names come from windows_isos
// in variables.pkrvars.hcl.
//
// Normal build: packer build -only="windows-base.proxmox-iso.base" -var-file=variables.pkrvars.hcl -var="image_os=win10" .
// Debug build:  packer build -only="windows-base.null.winrm" -var-file=variables.pkrvars.hcl -var="image_os=win10" -var="winrm_host=IP" .

build {
  name = "windows-base"

  sources = [
    "source.proxmox-iso.base",
    "source.null.winrm",
  ]

  provisioner "windows-restart" {
  }

  // Install Windows Updates using the rgl/packer-plugin-windows-update provisioner.
  // The provisioner handles multiple update/restart cycles automatically.
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -match 'Preview'",
      "exclude:$_.Title -match 'Beta'",
      "exclude:$_.Title -match 'Windows Recovery Environment'",
      "exclude:$_.InstallationBehavior.CanRequestUserInput",
      "include:$true",
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = "10m"
  }

  // Run after updates have been installed and the OS has restarted.
  // Disables hibernation, cleans the WU download cache, runs DISM
  // component cleanup, clears temp files / event logs, and zeroes
  // free space so Proxmox thin-provisioned storage can reclaim blocks.
  provisioner "powershell" {
    script = "${local.scripts_dir}/build/Optimize-BaseImage.ps1"
    // DISM /ResetBase alone can take 15-30 minutes; zeroing free space
    // adds another 5-20 minutes depending on disk size.
    timeout = "45m"
  }

  // Restart after DISM component cleanup (required for changes to take effect)
  provisioner "windows-restart" {
    restart_timeout = "10m"
  }

  provisioner "powershell" {
    script = "${local.scripts_dir}/build/Install-CloudBase.ps1"
  }

  provisioner "file" {
    source      = "${local.assets_dir}/base/config/"
    destination = "C:/Program Files/Cloudbase Solutions/Cloudbase-Init/conf"
  }

  provisioner "powershell" {
    inline = [
      "Set-Service cloudbase-init -StartupType Manual",
      "Stop-Service cloudbase-init -Force -Confirm:$false"
    ]
  }
}

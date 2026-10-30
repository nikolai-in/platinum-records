source "proxmox-iso" "base" {

  // PROXMOX CONNECTION CONFIGURATION
  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = var.proxmox_insecure
  username                 = var.proxmox_user
  password                 = var.proxmox_password != "" ? var.proxmox_password : null
  token                    = var.proxmox_token != "" ? var.proxmox_token : null
  node                     = var.node

  // BIOS & MACHINE CONFIGURATION
  bios    = "ovmf"
  machine = "q35"

  efi_config {
    efi_storage_pool  = var.efi_storage
    pre_enrolled_keys = true
    efi_type          = "4m"
  }

  // BOOT MEDIA CONFIGURATION
  boot_iso {
    iso_file         = "${var.iso_storage}:iso/${local.image_properties.windows_iso}"
    iso_storage_pool = var.iso_storage
    unmount          = true
  }

  additional_iso_files {
    iso_file         = "${var.iso_storage}:iso/${var.virtio_win_iso}"
    iso_storage_pool = var.iso_storage
    unmount          = true
    type             = "sata"
    index            = 1
  }

  additional_iso_files {
    cd_files = ["${local.scripts_dir}/Configure-RemotingForAnsible.ps1"]
    cd_content = {
      "autounattend.xml" = templatefile("${local.assets_dir}/unattend.pkrtpl", {
        user               = var.install_user,
        password           = var.install_password,
        cdrom_drive        = var.cdrom_drive,
        license_key        = local.image_properties.license_key,
        timezone           = var.timezone,
        index              = local.image_properties.image_index
        virtio_cdrom_drive = var.virtio_cdrom_drive
        driver_paths       = local.image_properties.driver_paths
      })
    }
    cd_label         = "Unattend"
    iso_storage_pool = var.iso_storage
    unmount          = true
    type             = "sata"
    index            = 0
  }

  // VM TEMPLATE CONFIGURATION
  template_name        = local.image_properties.base_template
  vm_id                = local.image_properties.base_vm_id
  vm_name              = "${local.image_properties.base_template}-build-${formatdate("YYYYMMDD-hhmmss", local.build_time)}"
  template_description = "Windows ${var.image_os} Base Image\nBirthday: ${formatdate("EEE, DD MMM YYYY hh:mm:ss ZZZ", local.build_time)}"
  os                   = local.image_properties.os_type

  // HARDWARE CONFIGURATION
  memory          = var.memory
  cores           = var.cores
  sockets         = var.socket
  cpu_type        = "host"
  scsi_controller = "virtio-scsi-pci"
  serials         = ["socket"]

  // CLOUD-INIT DRIVE (consumed by Cloudbase-Init on clones)
  cloud_init              = true
  cloud_init_storage_pool = var.cloud_init_storage

  // NETWORK CONFIGURATION
  network_adapters {
    model    = "virtio"
    bridge   = var.bridge
    vlan_tag = var.vlan_tag
  }

  // STORAGE CONFIGURATION
  disks {
    storage_pool = var.disk_storage
    type         = "scsi"
    disk_size    = local.image_properties.disk_size
    cache_mode   = "unsafe"
    format       = "raw"
  }

  // WINRM COMMUNICATION CONFIGURATION
  communicator   = "winrm"
  winrm_username = var.install_user
  winrm_password = var.install_password
  winrm_timeout  = "1h"
  winrm_port     = "5986"
  winrm_use_ssl  = true
  winrm_insecure = true

  // BOOT CONFIGURATION
  boot         = "order=scsi0"
  boot_wait    = "3s"
  boot_command = ["<enter><enter>", "\\efi\\boot\\bootx64.efi<enter><wait>", "<enter>"]
}

// Debug source: runs the provisioners against an already-running VM
# source "null" "winrm" {
#   communicator   = "winrm"
#   winrm_host     = var.winrm_host
#   winrm_username = var.install_user
#   winrm_password = var.install_password
#   winrm_timeout  = "1h"
#   winrm_port     = "5986"
#   winrm_use_ssl  = true
#   winrm_insecure = true
# }

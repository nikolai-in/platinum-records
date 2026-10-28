// Proxmox related variables
variable "proxmox_url" {
  type        = string
  description = "Proxmox Server URL"
}

variable "proxmox_insecure" {
  type        = bool
  description = "Allow insecure connections to Proxmox"
  default     = false
}

variable "proxmox_user" {
  type        = string
  description = "Proxmox username"
  sensitive   = true
}

variable "proxmox_password" {
  type        = string
  description = "Proxmox password"
  sensitive   = true
}

variable "node" {
  type        = string
  description = "Proxmox cluster node"
}

variable "iso_storage" {
  type        = string
  description = "Proxmox storage location for iso files"
  default     = "local"
}

variable "disk_storage" {
  type        = string
  description = "Disk storage location"
  default     = "local-lvm"
}

variable "efi_storage" {
  type        = string
  description = "Location of EFI storage on proxmox host"
  default     = "local-lvm"
}

variable "cloud_init_storage" {
  type        = string
  description = "Location of cloud-init files/iso/yaml config"
  default     = "local-lvm"
}

// VM hardware related variables
variable "memory" {
  type        = number
  description = "Amount of RAM in MB"
  default     = 8192
}

variable "cores" {
  type        = number
  description = "Amount of CPU cores"
  default     = 4
}

variable "socket" {
  type        = number
  description = "Amount of CPU sockets"
  default     = 1
}

variable "disk_size_gb" {
  type        = string
  description = "Size of the base image OS disk, including a unit suffix (e.g. '32G')"
  default     = null
}

variable "bridge" {
  type        = string
  description = "Network bridge name"
  default     = "vmbr0"
}

// Windows related variables

variable "license_keys" {
  type = object({
    win10 = string
    win22 = string
    win25 = string
  })
  description = "Windows license keys for different versions. Leave empty for evaluation versions."
  default = {
    win10 = ""
    win22 = ""
    win25 = ""
  }
  validation {
    condition = alltrue([
      for version, key in var.license_keys :
      key == "" || can(regex("^([A-Za-z0-9]{5}-){4}[A-Za-z0-9]{5}$", key))
    ])
    error_message = "Each license key must be either empty for evaluation version or in the format XXXXX-XXXXX-XXXXX-XXXXX-XXXXX."
  }
}

variable "virtio_win_iso" {
  type        = string
  description = "Virtio-win ISO file"
  default     = "virtio-win.iso"
}

variable "cdrom_drive" {
  type        = string
  description = "CD-ROM Drive letter for extra iso"
  default     = "D:"
}

variable "virtio_cdrom_drive" {
  type        = string
  description = "CD-ROM Drive letter for virtio-win iso"
  default     = "E:"
}

variable "timezone" {
  type        = string
  description = "Windows timezone"
  default     = "UTC"
}

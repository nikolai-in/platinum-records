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
  description = "Proxmox password (leave empty when using a token)"
  sensitive   = true
  default     = ""
}

variable "proxmox_token" {
  type        = string
  description = "Proxmox API token secret (leave empty when using a password)"
  sensitive   = true
  default     = ""
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

variable "tpm_storage" {
  type    = string
  default = null
}

variable "cloud_init_storage" {
  type        = string
  description = "Storage location for the cloud-init drive attached to the template"
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
  description = "Size of the base image OS disk, including a unit suffix (e.g. '64G'). Defaults to 64G for win10 and 32G for servers."
  default     = null
}

variable "bridge" {
  type        = string
  description = "Network bridge name"
  default     = "vmbr0"
}

variable "vm_ids" {
  type        = map(number)
  description = "Optional fixed Proxmox VM IDs for the resulting templates, keyed by image_os (e.g. { win22 = 9022 }). Missing or 0 lets Proxmox pick."
  default     = {}
}

// Windows related variables
variable "image_os" {
  type        = string
  description = "Which Windows version to build: win10, win22 or win25"
  validation {
    condition     = contains(["win10", "win11", "win16", "win19", "win22", "win25"], var.image_os)
    error_message = "The image_os must be one of: win10, win11, win16, win19, win22, win25."
  }
}

variable "windows_isos" {
  type        = map(string)
  description = "Installer ISO file name per image_os (win10, win11, win16, win19, win22, win25). Files must exist under iso/ in iso_storage. Only the entry for the selected image_os is required."
  validation {
    condition = alltrue([
      for os, iso in var.windows_isos :
      contains(["win10", "win11", "win16", "win19", "win22", "win25"], os) && trimspace(iso) != ""
    ])
    error_message = "The windows_isos keys must be win10, win11, win16, win19, win22, win25, and each value must be a non-empty ISO file name."
  }
}

variable "image_index" {
  type        = string
  description = "Override the WIM image index to install. Defaults: win10=1, win22/win25=4. Needed for multi-edition ISOs (list them with 'dism /Get-WimInfo')."
  default     = null
}

variable "license_keys" {
  type = object({
    win10 = string
    win11 = string
    win16 = string
    win19 = string
    win22 = string
    win25 = string
  })
  description = "Windows license keys for different versions. Leave empty for evaluation versions."
  default = {
    win10 = ""
    win11 = ""
    win16 = ""
    win19 = ""
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

variable "install_user" {
  type        = string
  default     = "Administrator"
  description = "Default Windows user"
}

// No default on purpose: an empty password breaks WinRM. Set it in
// variables.pkrvars.hcl or via the PKR_VAR_install_password environment variable.
variable "install_password" {
  type        = string
  sensitive   = true
  description = "Password for the default user"
}

variable "winrm_host" {
  type        = string
  description = "IP/host of an existing VM, only used by the debug build (source null.winrm)"
  default     = ""
}

# Example Packer variable file for Windows base image builds
# Copy this to variables.pkrvars.hcl and customize for your environment
# Build with: packer build -var-file=variables.pkrvars.hcl -var="image_os=win10" .

# Proxmox connection settings
proxmox_url      = "https://your-proxmox-server:8006/api2/json"
proxmox_user     = "your-user@pam"
proxmox_password = "your-password"
node             = "your-node-name"

# Storage configuration
iso_storage        = "local"
disk_storage       = "local-lvm"
efi_storage        = "local-lvm"
cloud_init_storage = "local-lvm"

# VM hardware settings
memory = 8192
cores  = 4
socket = 1

# Network settings
bridge = "vmbr0"

# Windows settings
install_user = "Administrator"
# Required. Set it here or export PKR_VAR_install_password
# install_password = "change-me"
timezone = "UTC"

# Installer ISOs, keyed by image_os. File names must match files under iso/ in
# iso_storage. Only the entry for the version you are building is needed.
windows_isos = {
  win10 = "en-us_windows_10_iot_enterprise_ltsc_2021_x64_dvd_257ad90f.iso"
  win11 = "en-us_windows_11_iot_enterprise_ltsc_2024_x64_dvd_f6b14814.iso"
  win16 = "en-us_windows_server_2016_eval_x64fre.iso"
  win19 = "en-us_windows_server_2019_eval_x64fre.iso"
  win22 = "en-us_windows_server_2022_eval_x64fre.iso"
  win25 = "en-us_windows_server_2025_eval_x64fre.iso"
}

# virtio drivers ISO (also in iso_storage)
virtio_win_iso = "virtio-win.iso"

# Optional: WIM index override (needed for multi-edition ISOs)
# image_index = "1"

# Optional: fixed template VM IDs per image_os (0 / unset = Proxmox picks)
# vm_ids = {
#   win10 = 9010
#   win11 = 9011
#   win16 = 9016
#   win19 = 9019
#   win22 = 9022
#   win25 = 9025
# }

# License keys (optional - leave empty for evaluation versions)
license_keys = {
  win10 = "" # "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
  win11 = "" # "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
  win16 = "" # "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
  win19 = "" # "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
  win22 = "" # "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
  win25 = "" # "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
}

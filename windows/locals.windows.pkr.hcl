locals {
  # Where the helper scripts and assets live, relative to this directory.
  # Change these two lines if your repo layout differs.
  scripts_dir = "${path.root}/scripts"
  assets_dir  = "${path.root}/assets"

  # Evaluated once so the temp VM name and template description share a timestamp
  build_time = timestamp()

  # Driver names that we want to include for Windows installation
  driver_names = [
    "Balloon",
    "NetKVM",
    "vioscsi",
    "viostor"
  ]

  # Windows version to virtio-win driver directory mapping
  windows_driver_versions = {
    "win10" = "w10"
    "win11" = "w11"
    "win16" = "2k16"
    "win19" = "2k19"
    "win22" = "2k22"
    "win25" = "2k25"
  }

  # Static per-version settings. The ISO file name is NOT here: it comes from
  # var.windows_isos so you can set it in variables.pkrvars.hcl.
  image_defaults = {
    "win10" = {
      image_index   = "1" # Enterprise / Enterprise LTSC single-edition ISOs. Override with var.image_index for multi-edition ISOs.
      disk_size     = "64G"
      os_type       = "win10"
      base_template = "windows-10-base"
    }
    "win11" = {
      image_index   = "1" # Enterprise / Enterprise LTSC single-edition ISOs. Override with var.image_index for multi-edition ISOs.
      disk_size     = "64G"
      os_type       = "win11"
      base_template = "windows-11-base"
    },
    "win16" = {
      image_index   = "1" # Datacenter
      disk_size     = "32G"
      os_type       = "win10" # Proxmox uses the "win10" OS type for Server 2016/2019
      base_template = "windows-2016-base"
    },
    "win19" = {
      image_index   = "1" # Datacenter
      disk_size     = "32G"
      os_type       = "win10" # Proxmox uses the "win10" OS type for Server 2016/2019
      base_template = "windows-2019-base"
    },
    "win22" = {
      image_index   = "4" # Datacenter (Desktop Experience)
      disk_size     = "32G"
      os_type       = "win11" # Proxmox uses the "win11" OS type for Server 2022/2025
      base_template = "windows-2022-base"
    }
    "win25" = {
      image_index   = "4" # Datacenter (Desktop Experience)
      disk_size     = "32G"
      os_type       = "win11"
      base_template = "windows-2025-base"
    }
  }

  selected_defaults = local.image_defaults[var.image_os]
  vm_id             = lookup(var.vm_ids, var.image_os, 0)

  image_properties = {
    windows_iso   = var.windows_isos[var.image_os]
    image_index   = coalesce(var.image_index, local.selected_defaults.image_index)
    disk_size     = coalesce(var.disk_size_gb, local.selected_defaults.disk_size)
    os_type       = local.selected_defaults.os_type
    base_template = local.selected_defaults.base_template
    base_vm_id    = local.vm_id == 0 ? null : local.vm_id
    license_key   = var.license_keys[var.image_os]
    driver_paths = [
      for driver in local.driver_names : "${driver}\\${local.windows_driver_versions[var.image_os]}\\amd64"
    ]
  }
}

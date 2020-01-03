variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-north1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable zone {
  description = "Zone"
  default     = "a"
}

variable private_key_path {
  description = "Path to the private key used by provisioners"
}

variable instance_count {
  description = "number of instances"
  default     = "1"
}

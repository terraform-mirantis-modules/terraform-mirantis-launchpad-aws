variable "cluster_name" {
  type        = string
  default     = ""
  description = "Global cluster name. Use this to override a dynamically created name."
  validation {
    condition     = length(var.cluster_name) < 11
    error_message = "Length of cluster_name cannot exceed 10 characters"
  }
}

variable "aws_region" {
  default = "us-east-2"
}

variable "aws_shared_credentials_file" {
  default = "~/.aws/credentials"
}

variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

variable "admin_password" {
  default = "mirantisadmin"
}

variable "admin_username" {
  default = "admin"
}

variable "master_count" {
  default = 1
}

variable "worker_count" {
  default = 3
}

variable "windows_worker_count" {
  default = 0
}

variable "msr_count" {
  default = 0
}

variable "master_type" {
  default = "m5.large"
}

variable "worker_type" {
  default = "m5.large"
}

variable "msr_type" {
  default = "m5.large"
}
variable "master_volume_size" {
  default = 100
}

variable "worker_volume_size" {
  default = 100
}

variable "msr_volume_size" {
  default = 100
}

variable "windows_administrator_password" {
  default = "w!ndozePassw0rd"
}

variable "mke_version" {
  default = "3.6.3"
}

variable "msr_version" {
  default = "2.9.11"
}

variable "msr_install_flags" {
  type        = list(string)
  default     = ["--ucp-insecure-tls"]
  description = "The MSR installer flags to use."
}

variable "mke_install_flags" {
  type        = list(string)
  default     = ["--nodeport-range=32768-35535"]
  description = "The MKE installer flags to use."
}

variable "mke_image_repo" {
  type        = string
  default     = "docker.io/mirantis"
  description = "The repository to pull the MKE images from."
}

variable "mcr_version" {
  type        = string
  default     = "23.0.3"
  description = "The mcr version to deploy across all nodes in the cluster."
}

variable "mcr_channel" {
  type        = string
  default     = "stable"
  description = "The channel to pull the mcr installer from."
}

variable "mcr_repo_url" {
  type        = string
  default     = "https://repos.mirantis.com"
  description = "The repository to source the mcr installer."
}

variable "kube_orchestration" {
  type        = bool
  default     = true
  description = "The option to enable/disable Kubernetes as the default orchestrator."
}

variable "msr_replica_config" {
  type        = string
  default     = "sequential"
  description = "Set to 'sequential' to generate sequential replica id's for cluster members, for example 000000000001, 000000000002, etc. ('random' otherwise)"
}

variable "msr_image_repo" {
  type        = string
  default     = "docker.io/mirantis"
  description = "The repository to pull the MSR images from."
}

variable "ssh_key_file_path" {
  type        = string
  default     = ""
  description = "If non-empty, use this path/filename as the ssh key file instead of generating automatically."
}

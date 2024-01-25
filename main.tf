provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = [var.aws_shared_credentials_file]
}

resource "random_string" "random" {
  length      = 6
  special     = false
  lower       = true
  min_upper   = 2
  min_numeric = 2
}

locals {
  cluster_name = var.cluster_name == "" ? random_string.random.result : var.cluster_name
}

module "vpc" {
  source       = "./modules/vpc"
  cluster_name = local.cluster_name
  host_cidr    = var.vpc_cidr
}

module "common" {
  source       = "./modules/common"
  cluster_name = local.cluster_name
  vpc_id       = module.vpc.id
}

module "masters" {
  source                      = "./modules/master"
  master_count                = var.master_count
  vpc_id                      = module.vpc.id
  cluster_name                = local.cluster_name
  subnet_ids                  = module.vpc.public_subnet_ids
  security_group_id           = module.common.security_group_id
  master_type                 = var.master_type
  master_volume_size          = var.master_volume_size
  image_id                    = module.common.image_id
  kube_cluster_tag            = module.common.kube_cluster_tag
  ssh_key                     = local.cluster_name
  instance_profile_name       = module.common.instance_profile_name
  additional_ingress_sg_rules = var.additional_master_ingress_sg_rules
}

module "msrs" {
  count                       = var.msr_count >= 1 ? 1 : 0
  source                      = "./modules/msr"
  msr_count                   = var.msr_count
  vpc_id                      = module.vpc.id
  cluster_name                = local.cluster_name
  subnet_ids                  = module.vpc.public_subnet_ids
  security_group_id           = module.common.security_group_id
  image_id                    = module.common.image_id
  msr_type                    = var.msr_type
  msr_volume_size             = var.msr_volume_size
  kube_cluster_tag            = module.common.kube_cluster_tag
  ssh_key                     = local.cluster_name
  instance_profile_name       = module.common.instance_profile_name
  additional_ingress_sg_rules = var.additional_msr_ingress_sg_rules
}

module "workers" {
  source                      = "./modules/worker"
  worker_count                = var.worker_count
  vpc_id                      = module.vpc.id
  cluster_name                = local.cluster_name
  subnet_ids                  = module.vpc.public_subnet_ids
  security_group_id           = module.common.security_group_id
  image_id                    = module.common.image_id
  worker_type                 = var.worker_type
  worker_volume_size          = var.worker_volume_size
  kube_cluster_tag            = module.common.kube_cluster_tag
  ssh_key                     = local.cluster_name
  instance_profile_name       = module.common.instance_profile_name
  additional_ingress_sg_rules = var.additional_worker_ingress_sg_rules
}

module "windows_workers" {
  source                         = "./modules/windows_worker"
  worker_count                   = var.windows_worker_count
  vpc_id                         = module.vpc.id
  cluster_name                   = local.cluster_name
  subnet_ids                     = module.vpc.public_subnet_ids
  security_group_id              = module.common.security_group_id
  image_id                       = module.common.windows_2019_image_id
  worker_type                    = var.worker_type
  worker_volume_size             = var.worker_volume_size
  kube_cluster_tag               = module.common.kube_cluster_tag
  instance_profile_name          = module.common.instance_profile_name
  windows_administrator_password = var.windows_administrator_password
  additional_ingress_sg_rules    = var.additional_windows_worker_ingress_sg_rules
}

locals {
  managers = [
    for host in module.masters.machines : {
      ssh = {
        address = host.public_ip
        user    = "ubuntu"
        keyPath = "./ssh_keys/${local.cluster_name}.pem"
      }
      role             = host.tags["Role"]
      privateInterface = "ens5"
    }
  ]
  msrs = var.msr_count >= 1 ? [
    for host in module.msrs[0].machines : {
      ssh = {
        address = host.public_ip
        user    = "ubuntu"
        keyPath = "./ssh_keys/${local.cluster_name}.pem"
      }
      role             = host.tags["Role"]
      privateInterface = "ens5"
    }
  ] : []
  workers = [
    for host in module.workers.machines : {
      ssh = {
        address = host.public_ip
        user    = "ubuntu"
        keyPath = "./ssh_keys/${local.cluster_name}.pem"
      }
      role             = host.tags["Role"]
      privateInterface = "ens5"
    }
  ]
  windows_workers = [
    for host in module.windows_workers.machines : {
      winrm = {
        address  = host.public_ip
        user     = "Administrator"
        password = var.windows_administrator_password
        useHTTPS = true
        insecure = true
      }
      role             = host.tags["Role"]
      privateInterface = "Ethernet 2"
    }
  ]

  hosts    = concat(local.managers, local.msrs, local.workers, local.windows_workers)
  key_path = var.ssh_key_file_path == "" ? "${path.root}/ssh_keys/${local.cluster_name}.pem" : var.ssh_key_file_path

  launchpad_1_4 = yamldecode(templatefile("${path.module}/templates/mke_cluster.1_4.tpl",
    {
      cluster_name = local.cluster_name
      key_path     = local.key_path

      hosts = local.hosts

      mcr_version           = var.mcr_version
      mcr_channel           = var.mcr_channel
      mcr_repoURL           = var.mcr_repo_url
      mcr_installURLLinux   = "https://get.mirantis.com/"
      mcr_installURLWindows = "https://get.mirantis.com/install.ps1"

      mke_version            = var.mke_version
      mke_image_repo         = var.mke_image_repo
      mke_admin_username     = var.admin_username
      mke_admin_password     = var.admin_password
      mke_san                = module.masters.lb_dns_name
      mke_kube_orchestration = var.kube_orchestration
      mke_installFlags       = var.mke_install_flags
      mke_upgradeFlags       = ["--force-recent-backup", "--force-minimums"]

      msr_version        = var.msr_version
      msr_image_repo     = var.msr_image_repo
      msr_count          = var.msr_count
      msr_installFlags   = var.msr_install_flags
      msr_replica_config = var.msr_replica_config

      cluster_prune = false

      msr_nfs_storage_url = ""
    }
  ))

}

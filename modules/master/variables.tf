variable "cluster_name" {}

variable "vpc_id" {}

variable "instance_profile_name" {}

variable "security_group_id" {}

variable "subnet_ids" {
  type = list(string)
}

variable "image_id" {}

variable "kube_cluster_tag" {}

variable "ssh_key" {
  description = "SSH key name"
}

variable "master_count" {
  default = 3
}

variable "master_type" {
  default = "m5.large"
}

variable "master_volume_size" {
  default = 100
}

variable "additional_ingress_sg_rules" {
  description = "Additional security group ingress rules to attach to the master nodes"
  type = list(object({
    from_port        = string
    to_port          = string
    protocol         = string
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    prefix_list_ids  = optional(list(string))
    self             = optional(bool)
    description      = optional(string)
  }))
  default = []
}

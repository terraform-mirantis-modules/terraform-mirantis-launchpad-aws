variable "cluster_name" {
  default = ""
}

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

variable "msr_count" {
  default = 3
}

variable "msr_type" {
  default = "m5.large"
}

variable "msr_volume_size" {
  default = 100
}

variable "additional_ingress_sg_rules" {
  description = "Additional security group ingress rules to attach to the msr nodes"
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

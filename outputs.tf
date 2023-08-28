output "mke_cluster" {
  value       = yamlencode(local.launchpad_1_4)
  description = "The launchpad template in yaml format"
}

output "hosts" {
  value       = concat(local.managers, local.msrs, local.workers, local.windows_workers)
  description = "All hosts in the cluster"
}

output "mke_lb" {
  value       = module.masters.lb_dns_name
  description = "LB path for the MKE ingress"
}

output "msr_lb" {
  value       = module.msrs.lb_dns_name
  description = "LB path for the MSR ingress"
}

locals {
  
  instance_cpu        = data.aws_ec2_instance_type.instance_type.default_vcpus * 1000 # convert it to millis
  instance_memory     = data.aws_ec2_instance_type.instance_type.memory_size          # memory_size is in MiB
  reserved_huge_pages = floor((local.instance_memory / 2) * var.huge_pages_reserved_percentage)

  kube_reserved_cpu    = format("%dm", floor(local.instance_cpu * var.kube_cpu_reserved_percent))
  kube_reserved_memory = format("%dMi", floor(local.instance_memory * var.kube_memory_reserved_percent))
  kube_reserved        = "--kube-reserved cpu=${local.kube_reserved_cpu},memory=${local.kube_reserved_memory}"

  system_reserved_cpu    = format("%dm", floor(local.instance_cpu * var.system_cpu_reserved_percent))
  system_reserved_memory = format("%dMi", floor(local.instance_memory * var.system_memory_reserved_percent))
  system_reserved        = "--system-reserved cpu=${local.system_reserved_cpu},memory=${local.system_reserved_memory}"

  combined_feature_gates = merge(var.default_feature_gates, var.additional_feature_gates)
  feature_gates          = local.combined_feature_gates != {} ? "--feature-gates ${join(",", [for a, b in local.combined_feature_gates : "${a}=${b}"])}" : ""

  cpu_manager_policy         = var.cpu_manager_policy != "" ? "--cpu-manager-policy ${var.cpu_manager_policy}" : ""
  cpu_manager_policy_options = var.cpu_manager_policy != "" ? "--cpu-manager-policy-options ${join(",", [for a, b in var.cpu_manager_policy_options : "${a}=${b}"])}" : ""

  kubelet_extra_args = "--kubelet-extra-args \"${join(" ", var.kubelet_extra_args)} ${local.system_reserved} ${local.kube_reserved} ${local.feature_gates} ${local.cpu_manager_policy} ${local.cpu_manager_policy_options}\""

  user_data = base64encode(templatefile("${path.module}/templates/user-data.tpl", { cluster_name = var.eks_cluster.name, para_store = var.cwagent_config, kubelet_extra_args = local.kubelet_extra_args, reserved_huge_pages = local.reserved_huge_pages }))

}
resource "kubernetes_service_account" "cluster-autoscaler" {
  metadata {
    name = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
    "eks.amazonaws.com/role-arn" = "arn:aws:iam::${module.vars.aws_accountid}:role/${module.vars.environ}-cluster-autoscaler"
    }
  }
}

resource "kubernetes_cluster_role_binding" "cluster-autoscaler" {
  metadata {
    name = "cluster-autoscaler-clusterbinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-autoscaler-clusterrole"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }
}

resource "kubernetes_role_binding" "cluster-autoscaler" {
  metadata {
    name = "cluster-autoscaler-rolebinding"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cluster-autoscaler-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role" "cluster-autoscaler" {
  metadata {
    name = "cluster-autoscaler-clusterrole"
  }

  rule {
    api_groups = [""]
    resources  = ["events","endpoints"]
    verbs      = ["create","patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/status"]
    verbs      = ["update"]
  }
  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    resource_names = ["cluster-autoscaler"]
    verbs      = ["get","update"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["watch","list","get","update"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods","services","replicationcontrollers","persistentvolumeclaims","persistentvolumes"]
    verbs      = ["watch","list","get"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs","cronjobs"]
    verbs      = ["watch","list","get"]
  }
  rule {
    api_groups = ["batch","extensions"]
    resources  = ["jobs"]
    verbs      = ["get","list","patch","watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["replicasets","daemonsets"]
    verbs      = ["watch","list","get"]
  }
  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["watch","list"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["daemonsets","replicasets","statefulsets"]
    verbs      = ["watch","list","get"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses","csinodes"]
    verbs      = ["watch","list","get"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["list","watch"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resource_names = ["cluster-autoscaler"]
    resources  = ["leases"]
    verbs      = ["get","update"]
  }
}

resource "kubernetes_role" "cluster-autoscaler" {
  metadata {
    name = "cluster-autoscaler-role"
    namespace = "kube-system"
  }
   rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create"]
  } 
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    resource_names = ["cluster-autoscaler-status"]
    verbs      = ["delete","get","update"]
  }
}


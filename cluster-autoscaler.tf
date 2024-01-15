# https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
# File is set to be "archived" until we decide to start using the autoscaler"

resource "kubernetes_pod_disruption_budget" "cluster-autoscaler" {
  metadata {
    name = "cluster-autoscaler"
    namespace = "kube-system"
  }
  spec {
    max_unavailable = 1
    selector {
      match_labels = {
        app = "cluster-autoscaler"
      }
    }
  }
}


resource "kubernetes_deployment" "cluster-autoscaler" {
  metadata {
    name = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      app = "cluster-autoscaler"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "cluster-autoscaler"
      }
    }

    template {
      metadata {
        labels = {
          app = "cluster-autoscaler"
          scrape_metrics = "true"
        }
      }

      spec {
        service_account_name = "cluster-autoscaler"
        container {
          name  = "cluster-autoscaler"
          image =  module.vars.autoscaler_image

          command = ["./cluster-autoscaler", "--cloud-provider=aws","--namespace=kube-system","--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${module.eks.cluster_id}" , "--logtostderr=true", "--stderrthreshold=info", "--v=4"]

          env {
            name = "AWS_REGION"
            value = module.vars.aws_region
          }

          port {
            container_port = 8085
          }

          liveness_probe {
            http_get {
              path = "/health-check"
              port = 8085
            }
          }

          resources {
            limits = {
              cpu    = "150m"
              memory = "300Mi"
            }
            requests = {
              cpu    = "150m"
              memory = "300Mi"
            }
          }
        }
      }
    }
  }
}

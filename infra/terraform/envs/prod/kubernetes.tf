
resource "kubernetes_deployment_v1" "app_deployment" {
  metadata {
    name      = "${var.project_name}-app"
    namespace = "default"
    labels = {
      App = "${var.project_name}-app"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "${var.project_name}-app"
      }
    }
    template {
      metadata {
        labels = {
          App = "${var.project_name}-app"
        }
      }
      spec {
        container {
          name  = "app-container"
          # Sua imagem Docker com a aplicação .NET (ou similar)
          image = "ghcr.io/mana-food-clean-architecture:latest"
          port {
            container_port = 8080
          }
          env {
            name  = "DB_ENDPOINT"
            value = module.aurora.cluster_endpoint # Passa o endpoint do DB
          }
        }
      }
    }
  }
}

# Exemplo de Service (LoadBalancer) para expor a aplicação
resource "kubernetes_service_v1" "app_service" {
  metadata {
    name      = "${var.project_name}-service"
    namespace = "default"
  }
  spec {
    selector = {
      App = kubernetes_deployment_v1.app_deployment.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 8080
    }
    type = "LoadBalancer" # Cria um AWS Classic Load Balancer ou NLB (dependendo das anotações)
  }
}
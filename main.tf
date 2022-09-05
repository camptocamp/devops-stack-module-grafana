resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

resource "argocd_project" "this" {
  metadata {
    name      = "grafana"
    namespace = var.argocd_namespace
    annotations = {
      "devops-stack.io/argocd_namespace" = var.argocd_namespace
    }
  }

  spec {
    description  = "grafana application project"
    source_repos = ["https://github.com/camptocamp/devops-stack-module-grafana.git"]

    destination {
      name      = "in-cluster"
      namespace = var.namespace
    }

    orphaned_resources {
      warn = true
    }

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }
  }
}

resource "random_password" "oauth2_cookie_secret" {
  length  = 16
  special = false
}

data "utils_deep_merge_yaml" "values" {
  input = [for i in concat(local.helm_values, var.helm_values) : yamlencode(i)]
}

# data "kubernetes_resource" "app_project" {
#   api_version = "argoproj.io/v1alpha1"
#   kind = "AppProject"

#   metadata {
#     name = argocd_project.this.metadata.0.name
#     namespace = var.argocd_namespace
#   }
# }

resource "argocd_application" "this" {
  metadata {
    name      = "grafana"
    namespace = var.argocd_namespace
  }

  timeouts {
    create = "15m"
    delete = "15m"
  }

  wait = true

  spec {
    project = argocd_project.this.id

    source {
      repo_url        = "https://github.com/camptocamp/devops-stack-module-grafana.git"
      path            = "charts/grafana"
      target_revision = "main"
      helm {
        values = data.utils_deep_merge_yaml.values.output
      }
    }

    destination {
      name      = "in-cluster"
      namespace = var.namespace
    }

    sync_policy {
      automated = {
        allow_empty = false
        prune       = true
        self_heal   = true
      }

      retry {
        backoff = {
          duration     = ""
          max_duration = ""
        }
        limit = "0"
      }

      sync_options = [
        "CreateNamespace=true"
      ]
    }
  }

  depends_on = [
    resource.null_resource.dependencies,
  ]
}

resource "null_resource" "this" {
  depends_on = [
    resource.argocd_application.this,
  ]
}

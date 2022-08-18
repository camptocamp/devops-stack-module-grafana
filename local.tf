locals {
  helm_values = [{
    grafana = {
      adminPassword = "${replace(local.grafana.admin_password, "\"", "\\\"")}"
      "grafana.ini" = {
        "auth.generic_oauth" = merge({
          enabled       = true
          allow_sign_up = true
          client_id     = "${replace(local.grafana.oidc.client_id, "\"", "\\\"")}"
          client_secret = "${replace(local.grafana.oidc.client_secret, "\"", "\\\"")}"
          scopes        = "openid profile email"
          auth_url      = "${replace(local.grafana.oidc.oauth_url, "\"", "\\\"")}"
          token_url     = "${replace(local.grafana.oidc.token_url, "\"", "\\\"")}"
          api_url       = "${replace(local.grafana.oidc.api_url, "\"", "\\\"")}"
        }, local.grafana.generic_oauth_extra_args)
        users = {
          auto_assign_org_role = "Editor"
        }
        server = {
          domain   = "${local.grafana.domain}"
          root_url = "https://%(domain)s" # TODO check this
        }
      }
      ingress = {
        enabled = true
        annotations = {
          "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
          "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
          "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-withclustername@kubernetescrd"
          "traefik.ingress.kubernetes.io/router.tls"         = "true"
          "ingress.kubernetes.io/ssl-redirect"               = "true"
          "kubernetes.io/ingress.allow-http"                 = "false"
        }
        hosts = [
          "${local.grafana.domain}",
          "grafana.apps.${var.base_domain}",
        ]
        tls = [
          {
            secretName = "grafana-tls"
            hosts = [
              "${local.grafana.domain}",
              "grafana.apps.${var.base_domain}",
            ]
          },
        ]
      }
    }
  }]

  grafana_defaults = {
    enable                   = true
    generic_oauth_extra_args = {}
    domain                   = "grafana.apps.${var.cluster_name}.${var.base_domain}"
    admin_password           = random_password.grafana_admin_password.result
  }

  grafana = merge(
    local.grafana_defaults,
    var.grafana,
  )
}

resource "random_password" "grafana_admin_password" {
  length  = 16
  special = false
}

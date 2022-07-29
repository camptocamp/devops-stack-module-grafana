# devops-stack-module-grafana

A [DevOps Stack](https://devops-stack.io) module to deploy and configure [Grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana).

## Usage

```hcl
module "grafana" {
  source = "git::https://github.com/camptocamp/devops-stack-module-grafana.git"
  cluster_name     = module.eks.cluster_name
  argocd_namespace = local.argocd_namespace
  base_domain      = module.eks.base_domain
  grafana = {
    oidc = module.oidc.oidc
  }
  depends_on = [module.monitoring, module.loki-stack]
}
```

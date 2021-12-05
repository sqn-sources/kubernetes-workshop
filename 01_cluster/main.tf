# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create a kubernetes cluster
resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = var.cluster_name
  region  = var.region
  version = "1.21.5-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    auto_scale = true
    min_nodes  = 2
    max_nodes  = 5
  }
}

resource "local_file" "kube_config" {
  filename          = "/root/.kube/config"
  sensitive_content = digitalocean_kubernetes_cluster.cluster.kube_config[0].raw_config
}

provider "kubernetes" {
  host                   = digitalocean_kubernetes_cluster.cluster.endpoint
  token                  = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = digitalocean_kubernetes_cluster.cluster.endpoint
    token                  = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
  }
}

resource "helm_release" "kubernetes_dashboard" {
  name             = "kubernetes-dashboard"
  repository       = "https://kubernetes.github.io/dashboard/"
  chart            = "kubernetes-dashboard"
  namespace        = "kubernetes-dashboard"
  create_namespace = true
  version          = "5.0.4"
}


#resource "helm_release" "nginx_ingress" {
#  name             = "ingress-nginx"
#  repository       = "https://kubernetes.github.io/ingress-nginx"
#  chart            = "ingress-nginx"
#  namespace        = "ingress-nginx"
#  create_namespace = true
#  version          = "v4.0.11"
#}
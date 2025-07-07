terraform {
  required_version = "~> 1.12.2"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
  }
}

provider "kubernetes" {
  alias       = "platform_cluster"
  config_path = local_file.kube_cluster_yaml.filename
}

provider "helm" {
  alias = "platform_cluster"
  kubernetes = {
    config_path = local_file.kube_cluster_yaml.filename
  }
}

locals {
  helm_nginx_name      = "nginx"
  helm_nginx_namespace = "nginx"
  helm_nginx_version   = "4.12.3"
  helm_nginx_repo      = "https://kubernetes.github.io/ingress-nginx"
  helm_nginx_chart     = "ingress-nginx"

  helm_argo_name       = "argo"
  helm_argo_namespace  = "argocd"
  helm_argo_version    = "7.7.15"
  helm_argo_repo       = "https://argoproj.github.io/argo-helm"
  helm_argo_chart      = "argo-cd"
  argo_values_file     = "argocd-values.yaml"
  argo_admin_pwd_file  = "argocd.txt"
}

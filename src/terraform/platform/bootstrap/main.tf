resource "local_file" "kube_cluster_yaml" {
  filename = "${path.root}/kube_config_cluster.yml"
  content  = file(var.kube_config)
}

resource "null_resource" "set_kube_context" {
  triggers = {
    build_number = timestamp() #trigger every time
  }

  provisioner "local-exec" {
    command     = <<EOT
      export KUBECONFIG="${local_file.kube_cluster_yaml.filename}"
      kubectl config use-context ${var.kube_context}
      kubectl get pods -A
    EOT
    interpreter = ["/bin/bash", "-c"]
    when        = create
  }

  depends_on = [local_file.kube_cluster_yaml]
}

// create key namespaces ahead of 1) creation of TLS secrets and 2) application of helm charts
resource "kubernetes_namespace" "k8s_namespaces" {
  provider = kubernetes.platform_cluster
  for_each = { for x in var.kubernetes_namespaces : lower(x) => x }
  metadata {
    name = each.value
  }
  lifecycle {
    ignore_changes = [metadata]
  }

  depends_on = [null_resource.set_kube_context]
}

resource "helm_release" "nginx" {
  provider         = helm.platform_cluster
  name             = local.helm_nginx_name
  namespace        = local.helm_nginx_namespace
  create_namespace = true
  repository       = local.helm_nginx_repo
  chart            = local.helm_nginx_chart
  version          = local.helm_nginx_version

  depends_on = [null_resource.set_kube_context, kubernetes_namespace.k8s_namespaces]
}

resource "local_file" "github_app_private_key_pem_reader" {
  filename = "${path.root}/github-app-key.pem"
  content  = file(var.github_app_private_key)
}

data "local_file" "github_app_private_key_pem" {
  filename = "${path.root}/github-app-key.pem"

  depends_on = [local_file.github_app_private_key_pem_reader]
}

# encrypt the default admin password for argocd
resource "null_resource" "core_argocd_admin_pwd_encrypter" {
  triggers = {
    build_number = timestamp() #trigger every time
  }

  provisioner "local-exec" {
    environment = {
      PWD_FILE = "${path.root}/${local.argo_admin_pwd_file}"
    }
    command     = <<EOT
      ARGO_PWD=${var.argo_pwd}
      htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/' >> "$PWD_FILE"
    EOT
    interpreter = ["/bin/bash", "-c"]
    when        = create
  }

  depends_on = [kubernetes_namespace.k8s_namespaces]
}

data "local_file" "core_argocd_admin_encrypted_pwd" {
  filename   = "${path.root}/${local.argo_admin_pwd_file}"

  depends_on = [null_resource.core_argocd_admin_pwd_encrypter]
}

resource "helm_release" "argocd" {
  provider         = helm.platform_cluster
  name             = local.helm_argo_name
  namespace        = local.helm_argo_namespace
  create_namespace = true
  repository       = local.helm_argo_repo
  chart            = local.helm_argo_chart
  version          = local.helm_argo_version
  values = [templatefile("${path.root}/${local.argo_values_file}", {
    githubAppID             = var.github_app_id
    githubAppInstallationID = var.github_app_installation_id
    githubOrgUrl            = var.github_org_url
    githubAppPrivateKey     = data.local_file.github_app_private_key_pem.content
    gitops-git-repo         = var.gitops_git_repo
    argo-server-pwd         = data.local_file.core_argocd_admin_encrypted_pwd.content
  })]

  depends_on = [null_resource.set_kube_context, helm_release.nginx, data.local_file.core_argocd_admin_encrypted_pwd]
}

resource "null_resource" "argocd_app_of_apps" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command     = <<EOT
      echo "Waiting for ArgoCD server to be ready..."
      sleep 30

      # Login using default admin password (replace with your actual setup or secret retrieval)
      argocd login localhost \
        --username admin \
        --password ${var.argo_pwd} \
        --insecure

      # Create the App of Apps pointing to k8s-gitops-root repo
      argocd app create root-app-${var.environment} \
        --repo ${var.gitops_git_repo} \
        --path ${var.gitops_git_repo_path}/${var.environment} \
        --dest-server https://kubernetes.default.svc \
        --dest-namespace argocd \
        --sync-policy automated --auto-prune --self-heal --set-finalizer \
        --sync-option CreateNamespace=true \
        --label name=app-of-apps \
        --grpc-web \
        --upsert
    EOT
    interpreter = ["/bin/bash", "-c"]
    when        = create
  }

  depends_on = [null_resource.set_kube_context, helm_release.argocd]
}

variable "kube_config" {
  description = "Absolute path to the kubeconfig file used to access the Kubernetes cluster."
  type        = string
}

variable "kube_context" {
  description = "The name of the Kubernetes context to activate within the kubeconfig."
  type        = string
}

variable "argo_pwd" {
  description = "The password for the ArgoCD admin user."
  type        = string
}

variable "kubernetes_namespaces" {
  description = "The target namespace for ArgoCD to get hosted."
  type        = list(string)
}

variable "environment" {
  description = "The environment for which the bootstrap is being performed."
  type        = string
  default     = "dev"
}

variable "github_app_id" {
  description = "GitHub App ID."
  type        = number
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID."
  type        = number
}

variable "github_hostname" {
  description = "GitHub host (github.com or GitHub Enterprise)."
  type        = string
  default     = "github.com"
}

variable "github_app_private_key" {
  description = "GitHub App private key in PEM format."
  type        = string
}

variable "github_org_url" {
  description = "GitHub host (github.com or GitHub Enterprise)."
  type        = string
  default     = "https://github.com/vanto-tech49"
}

variable "github_repo_owner" {
  description = "value"
  type        = string
  default     = "vanto-tech49"
}

variable "gitops_git_repo" {
  description = "GitHub repository name."
  type        = string
  default     = "https://github.com/vanto-tech49/k8s-gitops-root"
}

variable "gitops_git_repo_path" {
  description = "Path to the GitOps repository within the GitHub organization where all desired applications to be deployed are stored."
  type        = string
  default     = "apps"
}

variable "argocd_webhook_url" {
  description = "URL where GitHub should send webhook push events."
  type        = string
  default     = "https://localhost/api/webhook"
}

variable "gh_repo_hook" {
  type    = string
  default = "/repos/vanto-tech49/k8s-gitops-root/hooks"
}

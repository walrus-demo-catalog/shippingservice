terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

data "kubectl_path_documents" "manifest" {
  pattern = "${path.module}/manifest.yaml"
  vars = {
    namespace        = local.namespace
    image_registry   = var.image_registry
    image_repository = var.image_repository
    image_version    = var.image_version
    replicas         = var.replicas
  }
}

resource "kubectl_manifest" "manifest" {
  wait_for_rollout = false

  count     = length(data.kubectl_path_documents.manifest.documents)
  yaml_body = element(data.kubectl_path_documents.manifest.documents, count.index)
}

locals {
  namespace = coalesce(try(var.namespace, null), try(var.context["environment"]["namespace"], null))
}

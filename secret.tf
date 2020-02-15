locals {
  ca_private_key = var.ca_private_key_secret != "" && fileexists(var.ca_private_key_secret) ? file(var.ca_private_key_secret) : var.ca_private_key_secret
}

data "terraform_remote_state" "ca" {
  count   = var.ca_module_state == "" ? 0 : 1
  backend = "s3"

  config = {
    key    = var.ca_module_state
    bucket = var.tf_bucket
  }
}

resource "kubernetes_secret" "ca_pk" {
  metadata {
    name      = format("%s-%s-ca-pk", var.namespace, var.name)
    namespace = "kube-system"
  }

  data = {
    secret = coalesce(data.terraform_remote_state.ca.*.outputs.account_key_pem, local.ca_private_key)
  }
}

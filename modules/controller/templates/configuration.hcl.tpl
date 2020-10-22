disable_mlock = true

controller {
  database {
    url = "${database_url}"
  }

  name = "controller"
}

kms "awskms" {
  kms_key_id = "${kms_key_id}"
  purpose    = "root"
}

kms "awskms" {
  kms_key_id = "${kms_key_id}"
  purpose    = "worker-auth"
}

listener "tcp" {
  address     = "0.0.0.0"
  purpose     = "cluster"
  tls_disable = true
}

listener "tcp" {
  address     = "0.0.0.0"
  purpose     = "api"
  tls_disable = true
}

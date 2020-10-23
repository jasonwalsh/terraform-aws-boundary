disable_mlock = true

controller {
  database {
    url = "${database_url}"
  }

  name = "controller"
}

%{ for key in keys ~}
kms "awskms" {
  kms_key_id = "${key["key_id"]}"
  purpose    = "${key["purpose"]}"
}

%{ endfor ~}

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

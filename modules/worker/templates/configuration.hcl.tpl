disable_mlock = true

%{ for key in keys ~}
kms "awskms" {
  kms_key_id = "${key["key_id"]}"
  purpose    = "${key["purpose"]}"
}

%{ endfor ~}

listener "tcp" {
  address     = "{{ds.meta_data.local_ipv4}}:9202"
  purpose     = "proxy"
  tls_disable = true
}

worker {
  controllers = ${controllers}
  name        = "worker-{{v1.local_hostname}}"
  public_addr = "{{ds.meta_data.public_ipv4}}"
}

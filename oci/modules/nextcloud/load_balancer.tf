resource "oci_load_balancer" "public_ingress" {
  compartment_id             = var.compartment_id
  display_name               = "public-ingress"
  shape                      = "flexible"
  subnet_ids                 = [oci_core_subnet.public_subnet.id]
  network_security_group_ids = [oci_core_network_security_group.public.id, oci_core_network_security_group.private.id]

  shape_details {
    maximum_bandwidth_in_mbps = "10"
    minimum_bandwidth_in_mbps = "10"
  }
}

resource "oci_load_balancer_backend_set" "tcp_80_ingress" {
  load_balancer_id = oci_load_balancer.public_ingress.id
  name             = "tcp_80_ingress"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "TCP"
    port              = 80
    retries           = 3
    interval_ms       = 60000
    timeout_in_millis = 15000
  }
}

resource "oci_load_balancer_listener" "tcp_80_ingress" {
  default_backend_set_name = oci_load_balancer_backend_set.tcp_80_ingress.name
  load_balancer_id         = oci_load_balancer.public_ingress.id
  name                     = "tcp_80"
  port                     = 80
  protocol                 = "TCP"

  connection_configuration {
    idle_timeout_in_seconds = "15"
  }
}

resource "oci_load_balancer_backend" "tcp_80_backend" {
    backendset_name = oci_load_balancer_backend_set.tcp_80_ingress.name
    ip_address = oci_core_instance.nextcloud.private_ip
    load_balancer_id = oci_load_balancer.public_ingress.id
    port = 80
}

resource "oci_load_balancer_backend_set" "tcp_443_ingress" {
  load_balancer_id = oci_load_balancer.public_ingress.id
  name             = "tcp_443_ingress"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "TCP"
    port              = 443
    retries           = 3
    interval_ms       = 60000
    timeout_in_millis = 15000
  }
}

resource "oci_load_balancer_listener" "tcp_443_ingress" {
  default_backend_set_name = oci_load_balancer_backend_set.tcp_443_ingress.name
  load_balancer_id         = oci_load_balancer.public_ingress.id
  name                     = "tcp_443"
  port                     = 443
  protocol                 = "TCP"

  connection_configuration {
    idle_timeout_in_seconds = "15"
  }
}

resource "oci_load_balancer_backend" "tcp_443__backend" {
    backendset_name = oci_load_balancer_backend_set.tcp_443_ingress.name
    ip_address = oci_core_instance.nextcloud.private_ip
    load_balancer_id = oci_load_balancer.public_ingress.id
    port = 443
}
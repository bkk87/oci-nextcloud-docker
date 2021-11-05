resource "oci_core_instance" "nextcloud" {
    availability_domain = data.oci_identity_availability_domain.ad_domain.name
    compartment_id = var.compartment_id
    shape = "VM.Standard.A1.Flex"

    agent_config {

        are_all_plugins_disabled = false
        is_management_disabled = false
        is_monitoring_disabled = false
        plugins_config {
          desired_state = "ENABLED"
          name          = "Bastion"
        }
    }

    create_vnic_details {
        subnet_id        = oci_core_subnet.private_subnet.id
        assign_public_ip = false
        hostname_label   = "nextcloud"
    }

    display_name   = "nextcloud"

    instance_options {

        are_legacy_imds_endpoints_disabled = true
    }
    is_pv_encryption_in_transit_enabled = true

    metadata = {
      ssh_authorized_keys = var.ssh_public_key
      user_data           = data.template_cloudinit_config.instance.rendered
    }

    shape_config {
        ocpus         = 4
        memory_in_gbs = 24
    }
    source_details {
        source_id                = data.oci_core_images.aarch64.images.0.id
        source_type             = "image"
        boot_volume_size_in_gbs = 150
    }
    preserve_boot_volume = false
}

resource "oci_core_network_security_group" "public_ingress" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.nextcloud.id
  display_name   = "public-ingress-loadbalancer"
}

resource "oci_core_network_security_group_security_rule" "public_ingress_http" {
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.public_ingress.id
  protocol                  = "6"

  description = "http ingress"
  source      = "0.0.0.0/0"

  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "public_ingress_https" {
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.public_ingress.id
  protocol                  = "6"

  description = "https ingress"
  source      = "0.0.0.0/0"

  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

resource "oci_load_balancer" "public_ingress" {
  compartment_id             = var.compartment_id
  display_name               = "public-ingress"
  shape                      = "flexible"
  subnet_ids                 = [oci_core_subnet.public_subnet.id]
  network_security_group_ids = [oci_core_network_security_group.public_ingress.id]

  shape_details {
    maximum_bandwidth_in_mbps = "10"
    minimum_bandwidth_in_mbps = "10"
  }
}

resource "oci_load_balancer_backend_set" "http_ingress" {
  load_balancer_id = oci_load_balancer.public_ingress.id
  name             = "http_ingress"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "TCP"
    port              = 80
    retries           = 3
    interval_ms       = 60000
    timeout_in_millis = 15000
  }
}

resource "oci_load_balancer_listener" "http_ingress" {
  default_backend_set_name = oci_load_balancer_backend_set.http_ingress.name
  load_balancer_id         = oci_load_balancer.public_ingress.id
  name                     = "http"
  port                     = 80
  protocol                 = "TCP"

  connection_configuration {
    idle_timeout_in_seconds = "15"
  }
}

resource "oci_load_balancer_backend" "http_backend" {
    backendset_name = oci_load_balancer_backend_set.http_ingress.name
    ip_address = oci_core_instance.nextcloud.private_ip
    load_balancer_id = oci_load_balancer.public_ingress.id
    port = 80
}

resource "oci_load_balancer_backend_set" "https_ingress" {
  load_balancer_id = oci_load_balancer.public_ingress.id
  name             = "https_ingress"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "TCP"
    port              = 443
    retries           = 3
    interval_ms       = 60000
    timeout_in_millis = 15000
  }
}

resource "oci_load_balancer_listener" "https_ingress" {
  default_backend_set_name = oci_load_balancer_backend_set.https_ingress.name
  load_balancer_id         = oci_load_balancer.public_ingress.id
  name                     = "https"
  port                     = 443
  protocol                 = "TCP"

  connection_configuration {
    idle_timeout_in_seconds = "15"
  }
}

resource "oci_load_balancer_backend" "https_backend" {
    backendset_name = oci_load_balancer_backend_set.https_ingress.name
    ip_address = oci_core_instance.nextcloud.private_ip
    load_balancer_id = oci_load_balancer.public_ingress.id
    port = 443
}
resource "oci_core_vcn" "nextcloud" {
  dns_label      = "nextcloud"
  cidr_block     = var.vcn_subnet
  compartment_id = var.compartment_id
  display_name   = "nextcloud"
}

resource "oci_core_internet_gateway" "nextcloud" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.nextcloud.id
  display_name   = "nextcloud"
}

resource "oci_core_nat_gateway" "private_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.nextcloud.id
  display_name   = "private_subnet"
}

resource "oci_core_subnet" "public_subnet" {
  cidr_block     = var.public_subnet
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.nextcloud.id
  display_name   = "public_subnet"
  dns_label      = "public"
}

resource "oci_core_subnet" "private_subnet" {
  cidr_block                 = var.private_subnet
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.nextcloud.id
  display_name               = "private_subnet"
  route_table_id             = oci_core_route_table.private_subnet.id
  dns_label                  = "private"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_default_route_table" "nextcloud" {
  manage_default_resource_id = oci_core_vcn.nextcloud.default_route_table_id

  route_rules {
    network_entity_id = oci_core_internet_gateway.nextcloud.id

    description = "internet gateway"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_route_table" "private_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.nextcloud.id

  display_name = "private_subnet_natgw"

  route_rules {
    network_entity_id = oci_core_nat_gateway.private_subnet.id

    description = "private subnet to public internal"
    destination = "0.0.0.0/0"
  }
}


resource "oci_core_default_security_list" "default" {
  manage_default_resource_id = oci_core_vcn.nextcloud.default_security_list_id

  # TODO: check protocol is "all"
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "17"
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.vcn_subnet
    description = "SSH"

    tcp_options {
      max = 22
      min = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.vcn_subnet
    description = "HTTP"

    tcp_options {
      max = 80
      min = 80
    }
  }


  ingress_security_rules {
    protocol    = "6"
    source      = var.vcn_subnet
    description = "HTTPS"

    tcp_options {
      max = 443
      min = 443
    }

  }
}

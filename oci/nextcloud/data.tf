data "oci_identity_availability_domain" "ad_domain" {
  compartment_id = var.compartment_id
  ad_number      = var.ad_number
}

data "oci_core_images" "images" {
  compartment_id = var.compartment_id
}

data "oci_identity_compartment" "default" {
  id = var.compartment_id
}

data "template_file" "instance_cloud_init_file" {
  template = file("${path.module}/cloud-init/cloud-init.template.yaml")
}

data "template_cloudinit_config" "instance" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "server.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.instance_cloud_init_file.rendered
  }
}

data "oci_core_images" "aarch64" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "20.04"

  filter {
    name   = "display_name"
    values = ["^.*-aarch64-.*$"]
    regex  = true
  }
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_id
}

data "oci_core_boot_volumes" "boot_volumes" {
  availability_domain = data.oci_identity_availability_domain.ad_domain.name
  compartment_id = var.compartment_id
  depends_on = [ oci_core_instance.nextcloud ]
}
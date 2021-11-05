output "ad" {
  value = data.oci_identity_availability_domain.ad_domain
}

output "images_aarch64" {
  value = data.oci_core_images.aarch64.images.0
}

output "loadbalacer_ip" {
  value = oci_load_balancer.public_ingress.ip_addresses.0
}

output "user_secret_id" {
  value = oci_identity_customer_secret_key.this.id
}

output "user_secret_key" {
  value = oci_identity_customer_secret_key.this.key
}

output "bastion_session_id" {
  value =  oci_bastion_session.session.id
}

output "instance_private_ip" {
  value =  oci_core_instance.nextcloud.private_ip
}
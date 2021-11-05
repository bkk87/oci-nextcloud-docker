variable "tenancy_ocid" {}
variable "compartment_ocid" {}

variable "region" {
    default = "eu-frankfurt-1"
}

variable "ssh_public_key" {
    type = string
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqHVjE2EmoycqwcdX+8lCRgKjV3bzwM8OC2dnFctUF6kttJAzo2k7jJTnt7OgPME3RAI/UKVygWPxnzUspBOniTpu7/4U+43jjnVDqdQqbpCbm8ecradoimlrGkkPruLVF+LV4cnShs7cDzezkEFBTjuVdvskWiuSmhx52h3qsZWkiISdftUnLMilBYlEjN2ZcTRKUMn4OQpdeXpmIZZBEW4+OpLzm6jk0kakaaVXLPOZyDrFvo7fkM1NuuQPvHEjejqPlJe01miygFLh0HxHVJzr54/rthiZiy8QSmlJxZNIB/G74H8SLIEIB8AXmHJsOELqwbe881PeQvOwFsW9b ssh-key-2021-10-30"
}
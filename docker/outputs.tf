# output "mariadb_password" {
#   value = nonsensitive(random_password.mariadb_password.result)
# }

# output "mariadb_nextcloud_password" {
#   value     = nonsensitive(random_password.mariadb_nextcloud_password.result)
# }

output "nextcloud_admin_password" {
  value     = nonsensitive(random_password.nextcloud_password.result)
}

output "run_these_mariadb_commands" {
  value     = join("\n", [
    "1.   docker exec -i -t mariadb sh;\n", 
    "2.   mysql -uroot -p${nonsensitive(random_password.mariadb_password.result)};\n", 
    "3.   CREATE USER 'nextcloud'@'%' IDENTIFIED BY '${nonsensitive(random_password.mariadb_nextcloud_password.result)}';",
    "CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;",
    "GRANT ALL PRIVILEGES on nextcloud.* to 'nextcloud'@'%';",
    "FLUSH privileges;",
    "quit;"
  ])
}
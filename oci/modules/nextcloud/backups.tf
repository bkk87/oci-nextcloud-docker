# backups: 5 are within the always free tier:
# 4 daily and 
# 1 manual backup (not part of this terraform code)

resource "oci_core_volume_backup_policy" "daily" {
  compartment_id = var.compartment_id

  display_name = "daily-retention-4-days"
  schedules {
    backup_type       = "INCREMENTAL"
    period            = "ONE_DAY"
    retention_seconds = 345600 # 4 days
  }
}


resource "oci_core_volume_group" "daily" {
    availability_domain = data.oci_identity_availability_domain.ad_domain.name
    compartment_id = var.compartment_id
    source_details {
        type = "volumeIds"
        volume_ids = [data.oci_core_boot_volumes.boot_volumes.boot_volumes[0].id]
    }

    backup_policy_id = oci_core_volume_backup_policy.daily.id

    display_name = "daily-backups"
}


variable "region" {
    description = "AWS region"
    default     = "eu-central-1"
}

variable "db_snapshot_id" {
    description = "DB Snapshot ID. Only required if db needs to be pre-populated (e.g. testing envs)"
    default     = null
}

variable "region" {
  description = "aws region"
}
variable db_engine_version {
  description = "databse engine version"
}
variable db_instance_class {
  description = "data base instance class"
}
variable db_allocated_storage {
  description = "databse allocated storage"
}
variable db_name {
  description = "database name"
}
variable db_username {
  description = "database user name"
}
variable db_password {
  description = "database password"
}
variable db_port {
  description = "database port"
}
variable listen_port {
  description = "container listner port"
}
variable availability_zones {
  description = "available zones to deploy app in default vpc"
}
variable desired_count {
    description = "desired amount of instance to be spin up"
}
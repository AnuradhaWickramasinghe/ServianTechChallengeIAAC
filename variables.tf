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

variable "evaluation_periods" {
  description = "evaluation periods"
}

variable "period_down" {
 description = "period of down"
}

variable "period_up" {
  description = "period of dowupn"
}

variable "threshold_up" {
  description = "scale up threshold"
}

variable "threshold_down" {
  description = "scale down threshold"
}

variable "statistic" {
  
}

variable "min_capacity" {
  description = "min capacity"
}

variable "max_capacity" {
  description = "max capacity"
}

variable "lowerbound" {
  description = "lowerbound"
}

variable "upperbound" {
  description = "upperbound"
}

variable "scale_up_adjustment" {
  description = "scale up adjustment"
}

variable "scale_down_adjustment" {
  description = "scale down adjustment"
}

variable "datapoints_to_alarm_up" {
  description = "data poin to alarm up"
}

variable "datapoints_to_alarm_down" {
  description = "data poin to alarm down"
}
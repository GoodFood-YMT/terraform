variable "environment_suffix" {
  type        = string
  default     = ""
  description = "Suffix to append to the environment name"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "Location of the resources"
}

variable "project_name" {
  type        = string
  default     = "goodfood"
  description = "Name of the project"
}

variable "webapp_port" {
  type        = number
  default     = 3000
  description = "Port of the webapp"
}

variable "webapp_key" {
  type        = string
  default     = "ifPxYVPE2r_MogEXHHcUM90X3NJruV9g"
  description = "Key of the webapp"
}

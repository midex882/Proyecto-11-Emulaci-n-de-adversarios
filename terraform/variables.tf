variable "project_name" {
  description = "Prefijo de nombres para los recursos Docker."
  type        = string
  default     = "p11"
}

variable "wan_subnet" {
  description = "Red WAN simulada."
  type        = string
  default     = "172.30.10.0/24"
}

variable "dmz_subnet" {
  description = "Red DMZ simulada."
  type        = string
  default     = "172.30.20.0/24"
}

variable "target_ip" {
  description = "Direccion IP del servidor protegido."
  type        = string
  default     = "172.30.20.10"
}


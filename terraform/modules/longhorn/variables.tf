variable "nodes" {
  type        = set(string)
  description = "the set of hostnames that will be running longhorn"
}

variable "ssh_user" {
  type        = string
  default     = "dietpi"
  description = "username that terraform will use to ssh to the nodes"
}

variable "private_key" {
  type        = string
  default     = "mainframe"
  description = "the filename of the private key used to ssh to the nodes"
}

variable "private_key" {
  type        = string
  default     = "mainframe"
  description = "the filename of the private key used to ssh to the nodes"
}

variable "nodes" {
  type = list(object({
    hostname = string,
    ssh_user = string,
    roles    = list(string)
  }))
  description = "the list of nodes that will be bootstrapped"
}

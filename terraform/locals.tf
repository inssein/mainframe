locals {
  # username that terraform will use to ssh to the node(s)
  user = "pi"

  # the filename of the private key used to ssh to the node(s)
  private_key = "mainframe"

  # the list of nodes that will be bootstrapped
  nodes = {
    n01 = {
      hostname = "mainframe-n01"
      role     = ["gru"]
    },
    n02 = {
      hostname = "mainframe-n02"
      role     = ["minion"]
    },
    n03 = {
      hostname = "mainframe-n03"
      role     = ["minion"]
    },
    n04 = {
      hostname = "mainframe-n04"
      role     = ["minion"]
    }
  }

  # hostname of gru
  gru = one(toset([for each in local.nodes : each.hostname if contains(each.role, "gru")]))

  # hostnames of all minions
  minions = toset([for each in local.nodes : each.hostname if contains(each.role, "minion")])
}
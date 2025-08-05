nodes = [
  {
    hostname = "mainframe-n01"
    roles    = ["minion"],
    ssh_user = "dietpi"
  },
  {
    hostname = "mainframe-n02"
    roles    = ["minion"],
    ssh_user = "dietpi"
  },
  {
    hostname = "mainframe-n03"
    roles    = ["minion"],
    ssh_user = "dietpi"
  },
  {
    hostname = "mainframe-n04"
    roles    = ["minion"],
    ssh_user = "dietpi"
  },
  {
    hostname = "mainframe-gru"
    roles    = ["gru"],
    ssh_user = "truenas_admin"
  },
]

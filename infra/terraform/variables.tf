variable "region" {
  default = "us-east-2"
}

variable "tags" {
  type = map(string)
  default     = {
    "name" : "mixfast"
    "company" : "fiap"
  }
}

variable "name" {
  type = string
  default = "mixfast"
}

variable "subnet_ids" {
  type = list
  default = ["subnet-0fc6663036be9c87c", "subnet-062240e4d803849c4", "subnet-0309ddb3417cfc089"]
}

variable "security_group" {
  type = string
  default = "sg-00c29da1e1e89a896"
}
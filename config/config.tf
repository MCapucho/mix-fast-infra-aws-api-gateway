terraform {
  cloud {
    organization = "mixfast"

    workspaces {
      name = "mixfast-github-actions"
    }
  }
}
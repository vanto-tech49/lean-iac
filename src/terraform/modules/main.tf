resource "azurm_ressource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

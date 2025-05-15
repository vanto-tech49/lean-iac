module "resource-group" {
  source               = "./../../modules/azure-resource-group"
  ressource_group_name = var.ressource_group_name
  location             = var.location
}

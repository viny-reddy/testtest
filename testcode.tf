provider "azurerm"{
  features{}
}

module "rg" {
  source   = "./ResourceGroup/ResourceGroup"
  name     = var.rg_name
  location = var.rg_location
  rg_tags  = var.tags
}

module "vnet" {
  source               = "./virtual_network/virtual_network"
  virtual_network_name = var.virtual_network_name
  resource_group_name  = module.rg.az_resource_group_name
  location             = module.rg.az_resource_group_location
  vnet_address_space   = var.vnet_address_space
  vnet_tags            = var.tags
}

module "subnet" {
  source                        = "./subnet/subnet"
  subnet_name                   = var.subnet_name
  resource_group_name           = module.rg.az_resource_group_name
  virtual_network_name          = module.vnet.az_virtual_network_name
  subnet_address_prefix         = var.subnet_address_prefix
  create_subnet_nsg_association = false
}

module "Eventhub_namespace" {
  source                                = "./Event_hub/eventhub_namespace"
  resource_group_name                   = module.rg.az_resource_group_name
  location                              = module.rg.az_resource_group_location
  event_hub_namespace                   = var.event_hub_namespace
  event_hub_tags                        = var.tags
  create_eventhub_ns_authorization_rule = false
  //eventhub_authorization_rule_name      = var.eventhub_authorization_rule_name
}

module "event_hub" {
  source = "./Event_hub/eventhub"

  resource_group_name = module.rg.az_resource_group_name
  event_hub_name      = var.event_hub
  namespace_name      = module.Eventhub_namespace.az_eventhub_namespace_name
}
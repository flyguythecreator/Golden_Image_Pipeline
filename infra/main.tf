#########################################
### Compute Module for Compute Resources
#########################################
module "compute" {
  source                       = "./modules/compute"
}

##################################################################
### Networking Module for Networking and Authentication Resources
##################################################################
module "networking" {
  source                                                = "./modules/networking"
}



###########################################
### Security Module for Security Resources
###########################################
module "security" {
  source = "./modules/security"
}


#########################################
### Storage Module for Storage Resources
#########################################
module "storage" {
  source = "./modules/storage"
}
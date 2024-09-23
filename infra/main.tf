
# This is for hadoop Ansible playbooks
# Use null_resource to wait for each server to be ready and run Ansible playbook
# resource "null_resource" "run_ansible_playbook" {
#   count = length(cherryservers_server.demo-servers)


#   provisioner "local-exec" {
#     command     = "until nc -zv ${cherryservers_server.demo-servers[count.index].primary_ip} 22; do echo 'Waiting for SSH to be available...'; sleep 5; done"
#     working_dir = path.module
#   }


#   provisioner "local-exec" {
#     command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${cherryservers_server.demo-servers[count.index].primary_ip},' -u root --private-key //Path_to_private_key ../machine_image_config/demo_config.yml"
#     working_dir = path.module
#   }
# }

####################################################################
### CI/CD Pipeline Module for Production Development and Deployment
####################################################################
module "cicd" {
  source            = "./modules/cicd"
  # main_api_id_input = module.networking.main_api_id
}

#########################################
### Compute Module for Compute Resources
#########################################
module "compute" {
  source                       = "./modules/compute"
  # default_api_invoke_url_input = module.networking.default_api_invoke_url
  # default_api_stage_arn_input  = module.networking.default_api_stage_arn
  # main_api_id_input            = module.networking.main_api_id
}

##################################################################
### Networking Module for Networking and Authentication Resources
##################################################################
module "networking" {
  source                                                = "./modules/networking"
  # storage_s3_api_lambda_function_arn_input              = module.data-storage.storage_s3_api_lambda_function_arn
  # storage_s3_api_lambda_function_invoke_arn_input       = module.data-storage.storage_s3_api_lambda_function_invoke_arn
  # storage_dynamodb_api_lambda_function_arn_input        = module.data-storage.storage_dynamodb_api_lambda_function_arn
  # storage_dynamodb_api_lambda_function_invoke_arn_input = module.data-storage.storage_dynamodb_api_lambda_function_invoke_arn
  # default_api_lambda_function_invoke_arn_input          = module.data-storage.default_api_lambda_function_invoke_arn
  # default_api_lambda_function_arn_input                 = module.data-storage.default_api_lambda_function_arn
}



###########################################
### Security Module for Security Resources
###########################################
module "security" {
  source = "./modules/security"
  # main_api_id_input = module.networking.main_api_id
}


#########################################
### Storage Module for Storage Resources
#########################################
module "storage" {
  source = "./modules/storage"
  # main_api_id_input = module.networking.main_api_id
}
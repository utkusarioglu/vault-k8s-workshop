module "base" {
  source = "./modules/base"
}

module "deploy" {
  source = "./modules/deploy"
}

# module "ops" {
#   source = "./modules/ops"

#   depends_on = [
#     module.deploy
#   ]
# }

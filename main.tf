module "base" {
  source = "./modules/base"
}

module "deploy" {
  source = "./modules/deploy"
}

module "ops" {
  count  = 1
  source = "./modules/ops"

  depends_on = [
    module.deploy
  ]
}
